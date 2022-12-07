#lang racket

(define (compute-score-garbage chars depth score cancelled)
  (match chars
    ['() (error "Input ended with garbage")]
    [(list-rest #\! _ r) (compute-score-garbage r depth score cancelled)]
    [(cons #\> r) (compute-score-main r depth score cancelled)]
    [(cons _ r) (compute-score-garbage r depth score (add1 cancelled))]
  ))

(define (compute-score-main chars depth score cancelled)
  (match chars
    ['() (values score cancelled)]
    [(list-rest #\! _ r) (compute-score-main r depth score cancelled)]
    [(cons #\{ r) (compute-score-main r (add1 depth) (+ depth score) cancelled)]
    [(cons #\} r) (compute-score-main r (sub1 depth) score cancelled)]
    [(cons #\< r) (compute-score-garbage r depth score cancelled)]
    [(cons _ r) (compute-score-main r depth score cancelled)]
  ))

(define (compute-score input) (compute-score-main (string->list input) 1 0 0))

(define input-file "input")
(define input (file->string input-file))

(define-values (score cancelled) (compute-score input))
score
cancelled
