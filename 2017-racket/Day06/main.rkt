#lang racket

(define file-name "input")
(define input (map string->number (string-split (first (file->lines file-name)))))

(define (add-blocks banks amount start)
  (define num-banks (vector-length banks))
  (for ([i num-banks])
    (define to-add (+ (floor (/ amount num-banks))
                      (if (< i (modulo amount num-banks)) 1 0)))
    (define index (modulo (+ start i) num-banks))
    (vector-set! banks index (+ to-add (vector-ref banks index)))))

(define (redistribute banks)
  (define max-val (vector-argmax identity banks))
  (define max-bank (vector-member max-val banks))
  (vector-set! banks max-bank 0)
  (add-blocks banks max-val (+ max-bank 1)))

(struct lasso (total-length cycle-length) #:transparent)

(define (find-lasso banks steps seen)
  (define key (vector->list banks))
  (match (hash-ref seen key #f)
    [#f
     (redistribute banks)
     (find-lasso banks (+ steps 1) (hash-set seen key steps))]
    [n (lasso steps (- steps n))]))

(match-define (lasso part1 part2) (find-lasso (list->vector input) 0 (make-immutable-hash)))
part1
part2
