#lang racket

(define input-file-name "test")
(define input-lines (file->lines input-file-name))

(struct image (rows) #:transparent)
(struct rule (from to) #:transparent)

(define (parse-image s) (image (string-split s "/")))
(define (parse-rule s)
  (match-define (list l r) (string-split s " => "))
  (rule (parse-image l) (parse-image r)))
(define (parse-rules lines) (map parse-rule lines))

(define (rotate-image img)
  (match-define (image rows) img)
  (define transposed-rows (apply (curry map list) rows))
  (image (map reverse transposed-rows)))

(define (flip-image img)
  (match-define (image rows) img)
  (image (map reverse rows)))

(define (list-build-fun initial f size)
  (match size
    [0 (list initial)]
    [n (let ([next (f initial)]) (cons next (list-build-fun next f (sub1 size))))]))

(define (image-variants img)
  (define orig (list-build-fun img rotate-image 4))
  (define flipped (list-build-fun (flip-image img) rotate-image 4))
  (remove-duplicates (append orig flipped)))

(displayln (parse-rules input-lines))

(define testimg (image (list (list 1 2 3) (list 4 5 6) (list 7 8 9))))

(displayln testimg)
(displayln (rotate-image testimg))
(displayln (image-variants testimg))
