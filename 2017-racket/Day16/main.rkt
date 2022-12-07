#lang racket

(define input-file "input")
(define input (string-split (file->string input-file) ","))

(define (parse-move str) (cons (substring str 0 1) (string-split (substring str 1) "/")))
(define moves (map parse-move input))

(struct program-state (programs char-map offset) #:transparent)

(define (program-state->string state)
  (match-define (program-state programs _ offset) state)
  (define-values (start end) (split-at (vector->list programs) offset))
  (~a (list->string end) (list->string start)))

(define (init-state)
  (define programs (build-vector 16 (lambda (n) (integer->char (+ n (char->integer #\a))))))
  (program-state programs
                 (make-hash (for/list ([i 16]) (cons (vector-ref programs i) i)))
                 0))

(define (spin state n)
  (match-define (program-state programs char-map offset) state)
  (program-state programs char-map (modulo (- offset n) (vector-length programs))))

(define (partner state p1 p2)
  (match-define (program-state programs char-map offset) state)
  (define pos1 (hash-ref char-map p1))
  (define pos2 (hash-ref char-map p2))
  (hash-set! char-map p1 pos2)
  (hash-set! char-map p2 pos1)
  (vector-set! programs pos1 p2)
  (vector-set! programs pos2 p1)
  state)

(define (exchange state pos1 pos2)
  (match-define (program-state programs char-map offset) state)
  (define pos1-offset (modulo (+ pos1 offset) (vector-length programs)))
  (define pos2-offset (modulo (+ pos2 offset) (vector-length programs)))
  (define p1 (vector-ref programs pos1-offset))
  (define p2 (vector-ref programs pos2-offset))
  (partner state p1 p2))

(define (step move state)
  (match move
    [(list "s" n) (spin state (string->number n))]
    [(list "x" n1 n2) (exchange state (string->number n1) (string->number n2))]
    [(list "p" p1 p2) (partner state (car (string->list p1)) (car (string->list p2)))]))

(define (dance moves n [in-state (init-state)])
  (for*/fold ([state in-state])
             ([i n]
              [move moves])
             (step move state)))

(program-state->string (dance moves 1))

(define (find-cycle moves)
  (for/fold ([current (init-state)]
             [i 0])
             ([n (in-naturals)])
    #:break (eq? (program-state->string current) "abcdefghijklmnop")
    (when (= 0 (modulo i 1000)) (displayln i))
    (values (dance moves 1 current) (add1 i))))

(find-cycle moves)
