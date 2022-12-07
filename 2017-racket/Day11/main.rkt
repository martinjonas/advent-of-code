#lang racket

(require rackunit)

(define input-file "input")
(define input (file->string input-file))

(define (string->hex-position s)
  (match s
    ["n" (list 0 1 (- 1))]
    ["s" (list 0 (- 1) 1)]
    ["ne" (list 1 0 (- 1))]
    ["sw" (list (- 1) 0 1)]
    ["se" (list 1 (- 1) 0)]
    ["nw" (list (- 1) 1 0)]))

(define (hex-position-distance pos) (/ (apply + (map abs pos)) 2))

(define (run moves)
  (for/fold ([pos (list 0 0 0)]
             [max-dist 0])
            ([move (map string->hex-position moves)])
    (let ([new-pos (map + pos move)]) (values new-pos (max max-dist (hex-position-distance new-pos))))))

(define (part1 input)
  (define moves (string-split input ","))
  (define-values (end max-dist) (run moves))
  (hex-position-distance end))

(define (part2 input)
  (define moves (string-split input ","))
  (define-values (end max-dist) (run moves))
  max-dist)

(check-eq? (part1 "ne,ne,ne") 3)
(check-eq? (part1 "ne,ne,sw,sw") 0)
(check-eq? (part1 "ne,ne,s,s") 2)
(check-eq? (part1 "se,sw,se,sw,sw") 3)

(part1 input)
(part2 input)
