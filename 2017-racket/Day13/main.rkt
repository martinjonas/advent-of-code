#lang racket

(define input-file "input")
(define input (file->lines input-file))

(struct layer (depth range) #:transparent)
(define (string->layer s) (apply layer (map string->number (string-split s ": "))))
(define layers (map string->layer input))

(define (compute-catches layers delay)
  (filter-map (match-lambda
                [(layer d r) (if (= 0 (modulo (+ d delay) (* 2 (sub1 r))))
                                 (* d r)
                                 #f)])
                layers))

(define (part1 layers)
  (apply + (compute-catches layers 0)))

(define (part2 layers)
  (for/first ([d (in-naturals)] #:when (null? (compute-catches layers d)))
    d))

(part1 layers)
(part2 layers)
