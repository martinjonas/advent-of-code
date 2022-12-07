#lang racket

(define file-name "input")
(define input (map string-split (file->lines file-name)))

(count (negate check-duplicates) input)

(define (canonize-string s) (list->string (sort (string->list s) char<?)))
(count (negate (lambda (line) (check-duplicates line #:key canonize-string))) input)
