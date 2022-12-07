#lang racket

(define file-name "input")
(define input (file->lines file-name))
(define numbers (map (lambda (line) (map string->number (string-split line))) input))

(define (max-min-difference numbers)
  (- (apply max numbers) (apply min numbers)))

(define (part1 numbers)
  (apply + (map max-min-difference numbers)))

(part1 numbers)

(define (divide-or-false a b)
  (if (and (> a b) (= (modulo a b) 0))
      (/ a b)
      #f))

(define (divisible-result numbers)
  (for*/or ([n1 numbers] [n2 numbers])
    (divide-or-false n1 n2)))

(define (part2 numbers)
  (apply + (map divisible-result numbers)))

(part2 numbers)
