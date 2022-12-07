#lang racket

(define input-file "input")

(define numbers (map string->number (file->lines input-file)))
(define numbers-set (list->set numbers))

(define (two-sum numbers target)
  (match (findf (lambda (n) (set-member? numbers (- target n))) (set->list numbers))
          [#f #f]
          [n (list n (- target n))]))

(define (three-sum numbers target)
  (match (ormap (lambda (n) (two-sum numbers (- target n))) (set->list numbers))
          [#f #f]
          [ns (cons (- target (foldl + 0 ns)) ns)]))

"Part 1:"
(foldl * 1 (two-sum numbers-set 2020))
"Part 2:"
(foldl * 1 (three-sum numbers-set 2020))
