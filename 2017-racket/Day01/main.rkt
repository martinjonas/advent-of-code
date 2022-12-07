#lang racket

(require rackunit)

(define file-name "input")
(define input (first (file->lines file-name)))
(define (decimal-char->number ch) (- (char->integer ch) (char->integer #\0)))
(define (decimal-string->numbers s) (map decimal-char->number (string->list s)))

(define (list-rotate xs n)
  (define-values (start end) (split-at xs n))
  (append end start))

(define (filter-with-consecutive xs n)
  (map car (filter (curry apply =) (map list xs (list-rotate xs n)))))

(define (part1 input)
  (define numbers (decimal-string->numbers input))
  (apply + (filter-with-consecutive numbers 1)))

(check-equal? (part1 "1122") 3)
(check-equal? (part1 "1111") 4)
(check-equal? (part1 "1234") 0)
(check-equal? (part1 "91212129") 9)

(part1 input)

(define (part2 input)
  (define numbers (decimal-string->numbers input))
  (apply + (filter-with-consecutive numbers (/ (length numbers) 2))))

(check-equal? (part2 "1212") 6)
(check-equal? (part2 "1221") 0)
(check-equal? (part2 "123425") 4)
(check-equal? (part2 "123123") 12)
(check-equal? (part2 "12131415") 4)

(part2 input)
