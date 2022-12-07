#lang racket

(define input-file-name "input")
(define instructions (list->vector (map string-split (file->lines input-file-name))))

(define-struct state (instructions pc context outputs) #:transparent)

(define (state-get-value st val)
  (match-define (state instructions pc context outputs) st)
  (or (string->number val) (hash-ref context val 0)))

(define (state-set-value st reg val)
  (match-define (state instructions pc context outputs) st)
  (hash-set context reg val))

(define (state-apply st res op . args)
  (state-set-value st res (apply op (map (curry state-get-value st) args))))

(define (eval st)
  (match-define (state instructions pc context outputs) st)
  (match (vector-ref instructions pc)
    [(list "snd" reg)
     (eval (struct-copy state st [pc (add1 pc)] [outputs (cons (state-get-value st reg) outputs)]))]
    [(list "set" reg val)
     (eval (struct-copy state st [pc (add1 pc)] [context (state-set-value st reg (state-get-value st val))]))]
    [(list "add" reg val)
     (eval (struct-copy state st [pc (add1 pc)] [context (state-apply st reg + val reg)]))]
    [(list "mul" reg val)
     (eval (struct-copy state st [pc (add1 pc)] [context (state-apply st reg * val reg)]))]
    [(list "mod" reg val)
     (eval (struct-copy state st [pc (add1 pc)] [context (state-apply st reg modulo reg val)]))]
    [(list "rcv" reg)
     (if (= 0 (state-get-value st reg))
         (eval (struct-copy state st [pc (add1 pc)]))
         (car outputs))]
    [(list "jgz" reg val)
     (eval (struct-copy state st [pc (+ pc (if (positive? (state-get-value st reg)) (state-get-value st val) 1))]))]))

(define (part1 instructions)
  (eval (state instructions 0 (make-immutable-hash) '())))

(part1 instructions)

(define (eval2 st inputs)
  (match-define (state instructions pc context outputs) st)
  (match (vector-ref instructions pc)
    [(list  "snd" reg)
     (eval2 (struct-copy state st [pc (add1 pc)] [outputs (cons (state-get-value st reg) outputs)]) inputs)]
    [(list "set" reg val)
     (eval2 (struct-copy state st [pc (add1 pc)] [context (state-set-value st reg (state-get-value st val))]) inputs)]
    [(list "add" reg val)
     (eval2 (struct-copy state st [pc (add1 pc)] [context (state-apply st reg + val reg)]) inputs)]
    [(list "mul" reg val)
     (eval2 (struct-copy state st [pc (add1 pc)] [context (state-apply st reg * val reg)]) inputs)]
    [(list "mod" reg val)
     (eval2 (struct-copy state st [pc (add1 pc)] [context (state-apply st reg modulo reg val)]) inputs)]
    [(list "rcv" reg)
     (match inputs
       ('() (cons 'need-inputs st))
       ((cons input remaining) (eval2 (struct-copy state st [pc (add1 pc)] [context (state-set-value st reg input)]) remaining)))]
    [(list "jgz" reg val)
     (eval2 (struct-copy state st [pc (+ pc (if (positive? (state-get-value st reg)) (state-get-value st val) 1))]) inputs)]))

(define (part2 instructions)
  (define (run-parallel state1 state2 inputs1 sent1)
    (match-define (cons 'need-inputs state1_new) (eval2 state1 inputs1))
    (match-define (cons 'need-inputs state2_new) (eval2 state2 (reverse (state-outputs state1_new))))
    (if (null? (state-outputs state2_new))
        (+ sent1 (length (state-outputs state2_new)))
        (run-parallel
         (struct-copy state state1_new [outputs '()])
         (struct-copy state state2_new [outputs '()])
         (reverse (state-outputs state2_new))
         (+ sent1 (length (state-outputs state2_new))))))

    (run-parallel (state instructions 0 (hash-set (make-immutable-hash) "p" 0) '())
                  (state instructions 0 (hash-set (make-immutable-hash) "p" 1) '())
                  '()
                  0))

(part2 instructions)
