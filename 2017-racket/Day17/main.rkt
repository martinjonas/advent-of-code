#lang racket

(define-struct state (current next-map) #:transparent #:mutable)

(define (move! current-state n)
  (when (positive? n)
    (match-define (state current next-map) current-state)
    (define next-val (vector-ref next-map current))
    (set-state-current! current-state next-val)
    (move! current-state (sub1 n))))

(define (insert! current-state v)
  (match-define (state current next-map) current-state)
  (define next-val (vector-ref next-map current))
  (vector-set! next-map current v)
  (vector-set! next-map v next-val)
  (set-state-current! current-state v))

(define (move-and-insert! current-state v step-size)
  (move! current-state step-size)
  (insert! current-state v)
  current-state)

(define (insert-from-to! current-state step-size from to)
  (for ([i (in-range from (add1 to))])
    (move-and-insert! current-state i step-size)))

(define (part1 step-size)
  (define max-value 2017)
  (define current-state (state 0 (make-vector (add1 max-value))))
  (insert-from-to! current-state step-size 1 max-value)
  (vector-ref (state-next-map current-state) max-value))

(define (part2 step-size)
  (define max-value 50000000)
  (define current-state (state 0 (make-vector (add1 max-value))))
  (insert-from-to! current-state step-size 1 max-value)
  (vector-ref (state-next-map current-state) 0))

(part1 354)
(part2 354)

