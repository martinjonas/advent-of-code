#lang racket

(define file-name "input")
(define input (list->vector (map string->number (file->lines file-name))))

(define (run current instructions steps update-func)
  (cond
    [(or (< current 0) (>= current (vector-length instructions))) steps]
    [else
     (define offset (vector-ref instructions current))
     (vector-set! instructions current (update-func offset))
     (run (+ current offset) instructions (+ steps 1) update-func)]))

(define (part1 input) (run 0 (vector-copy input) 0 (lambda (o) (+ o 1))))
(define (part2 input) (run 0 (vector-copy input) 0 (lambda (o) (if (>= o 3) (- o 1) (+ o 1)))))

(part1 input)
(part2 input)
