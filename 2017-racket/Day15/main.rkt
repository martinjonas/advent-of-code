#lang racket

(require racket/stream)

(define modulus 2147483647)
(define compare-modulus (expt 2 16))
(define seed-a 873)
(define seed-b 583)

(define (generator seed factor) (stream-cons seed (generator (modulo (* seed factor) modulus) factor)))

(define (part1 seed-a seed-b)
  (define gen-a (stream-rest (generator seed-a 16807)))
  (define gen-b (stream-rest (generator seed-b 48271)))
  (for/sum ([i 40000000]
            [a gen-a]
            [b gen-b])
    (if (= (modulo a compare-modulus) (modulo b compare-modulus)) 1 0)))

(part1 seed-a seed-b)

(define (picky-generator seed factor pick)
  (if (= 0 (modulo seed pick))
      (stream-cons seed (picky-generator (modulo (* seed factor) modulus) factor pick))
      (picky-generator (modulo (* seed factor) modulus) factor pick)))

(define (part2 seed-a seed-b)
  (define picky-gen-a (picky-generator seed-a 16807 4))
  (define picky-gen-b (picky-generator seed-b 48271 8))
  (for/sum ([i 5000000]
            [a picky-gen-a]
            [b picky-gen-b])
    (if (= (modulo a compare-modulus) (modulo b compare-modulus)) 1 0)))

(part2 seed-a seed-b)
