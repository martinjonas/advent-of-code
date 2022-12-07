#lang racket

(define input-file "input")
(define input (first (file->lines input-file)))

(define-syntax-rule (vector-swap! v pos1 pos2)
  (let ([tmp (vector-ref v pos1)])
    (vector-set! v pos1 (vector-ref v pos2))
    (vector-set! v pos2 tmp)))

(define (rotate! v pos len)
  (define size (vector-length v))
  (define (safe-index i) (modulo i size))
  (define end (+ pos len (- 1)))
  (for ([i (exact-floor (/ len 2))])
    (vector-swap! v (safe-index (+ pos i)) (safe-index (- end i)))))

(define (run v current skip rotations)
  (match rotations
    ['() (values current skip)]
    [(cons len r)
     (rotate! v current len)
     (run v (+ current len skip) (add1 skip) r)]))

(define (part1 len input)
  (define numbers (map string->number (string-split input ",")))
  (define v (build-vector len identity))
  (run v 0 0 numbers)
  (* (vector-ref v 0) (vector-ref v 1)))

(part1 256 input)

(define (sparse->dense l)
  (cond
    [(null? l) '()]
    [else (define-values (start end) (split-at l 16))
          (cons (apply bitwise-xor start) (sparse->dense end))]))

(define (part2 len input)
  (define numbers (append (map char->integer (string->list input)) '(17 31 73 47 23)))
  (define v (build-vector len identity))
  (for/fold ([current 0]
             [skip 0])
            ([i 64])
    (run v current skip numbers))
  (define dense-hash (sparse->dense (vector->list v)))
  (define hex-strings (map (lambda (ch) (~r ch #:base 16 #:min-width 2 #:pad-string "0")) dense-hash))
  (apply string-append hex-strings))

(displayln (part2 256 input))
