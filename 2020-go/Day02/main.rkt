#lang racket

(define input-file "input")

(struct rule (n1 n2 ch pass) #:transparent)

(define (parse-rule str)
  (match (regexp-match #px"(\\d+)-(\\d+) (.): (.*)" str)
    [(list _ n1 n2 ch pass) (rule (string->number n1) (string->number n2) ch pass)]))

(define rules (map parse-rule (file->lines input-file)))

(define (count-valid rules validation-function)
  (length (filter validation-function rules)))

(define (valid-1 rule)
  (let ([c-count (length (regexp-match* (rule-ch rule) (rule-pass rule)))])
    (and (<= (rule-n1 rule) c-count) (<= c-count (rule-n2 rule)))
  ))

(define (valid-2 rule)
  (define (is-ch n) (eq? (string-ref (rule-ch rule) 0) (string-ref (rule-pass rule) (- n 1))))
  (xor (is-ch (rule-n1 rule)) (is-ch (rule-n2 rule)))
  )

(printf "Part 1: ~a\n" (count-valid rules valid-1))
(printf "Part 2: ~a\n" (count-valid rules valid-2))
