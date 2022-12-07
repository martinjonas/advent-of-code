#lang racket

(define input-file-name "test")
(define lines (file->lines input-file-name))

(define (parse-line line)
  (match-define (list _ x y z) (regexp-match #px"p=<(.?\\d+),(.?\\d+),(.?\\d+)>" line))
  (list x y z))

(map parse-line lines)
