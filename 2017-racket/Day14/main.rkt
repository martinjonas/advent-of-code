#lang racket

(define input "hwlqcszp")

(define-syntax-rule (vector-swap! v pos1 pos2)
  (let ([tmp (vector-ref v pos1)])
    (vector-set! v pos1 (vector-ref v pos2))
    (vector-set! v pos2 tmp)))

(define (rotate! v pos len)
  (define size (vector-length v))
  (define (safe-index i) (modulo i size))
  (define end (+ pos len (- 1)))
  (for ([i (exact-floor (/ len 2))])
    (vector-swap! v (safe-index (+ pos i)) (safe-index (- end i)))))

(define (run v current skip rotations)
  (match rotations
    ['() (values current skip)]
    [(cons len r)
     (rotate! v current len)
     (run v (+ current len skip) (add1 skip) r)]))

(define (sparse->dense l)
  (cond
    [(null? l) '()]
    [else (define-values (start end) (split-at l 16))
          (cons (apply bitwise-xor start) (sparse->dense end))]))

(define (compute-binary-knot-hash input)
  (define numbers (append (map char->integer (string->list input)) '(17 31 73 47 23)))
  (define v (build-vector 256 identity))
  (for/fold ([current 0]
             [skip 0])
            ([i 64])
    (run v current skip numbers))
  (define dense-hash (sparse->dense (vector->list v)))
  (define binary-strings (map (lambda (ch) (~r ch #:base 2 #:min-width 8 #:pad-string "0")) dense-hash))
  (apply string-append binary-strings))

(struct pos (col row) #:transparent)

(define (pos-neighbors p)
  (match-define (pos c r) p)
  (list (pos (add1 c) r)
        (pos (sub1 c) r)
        (pos c (add1 r))
        (pos c (sub1 r))))

(define (binary-line->set line row-num)
  (for/fold ([h (set)])
            ([ch (string->list line)]
             [i (in-naturals)]
             #:when (eq? ch #\1))
    (set-add h (pos i row-num))))

(define (compute-plan input)
  (for/fold
      ([ones (set)])
      ([i 128])
    (define hash (compute-binary-knot-hash (format "~a-~a" input i)))
    (set-union ones (binary-line->set hash i))))

(define (part1 plan)
  (set-count plan))

(define input-plan (compute-plan input))
(part1 input-plan)

(define (remove-connected current plan)
  (cond
    [(not (set-member? plan current)) plan]
    [else (foldl remove-connected (set-remove plan current) (pos-neighbors current))]))

(define (count-groups plan acc)
  (cond
    [(set-empty? plan) acc]
    [else (count-groups (remove-connected (set-first plan) plan) (add1 acc))]))

(define (part2 plan)
  (count-groups plan 0))

(part2 input-plan)

