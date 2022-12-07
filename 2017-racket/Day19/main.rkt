#lang racket

(define input-file-name "input")
(define network (list->vector (map (lambda (line) (list->vector (string->list line))) (file->lines input-file-name))))

(define (network-width network)
  (vector-length (vector-ref network 0)))

(struct vec2 (x y) #:transparent)

(define (vec2-add v1 v2)
  (match-define (vec2 x1 y1) v1)
  (match-define (vec2 x2 y2) v2)
  (vec2 (+ x1 x2) (+ y1 y2)))

(define (vec2-rot-l v)
  (match-define (vec2 x y) v)
  (vec2 (- y) x))

(define (vec2-rot-r v)
  (match-define (vec2 x y) v)
  (vec2 y (- x)))

(define (network-set? network pos)
  (match-define (vec2 x y) pos)
  (and (>= x 0)
      (>= y 0)
      (< y (vector-length network))
      (< x (vector-length (vector-ref network y)))
      (not (eq? (vector-ref (vector-ref network y) x) #\space))))

(define (network-ref network pos)
  (match-define (vec2 x y) pos)
  (vector-ref (vector-ref network y) x))

(define (network-entrance network)
  (for/first ([x (in-naturals)]
              #:when (network-set? network (vec2 x 0)))
    (vec2 x 0)))

(define (go network pos dir steps)
  (when (char-alphabetic? (network-ref network pos)) (display (network-ref network pos)))
  (define next-pos-dir
    (for/or ([dir_to_try (list dir (vec2-rot-l dir) (vec2-rot-r dir))]
             #:when (network-set? network (vec2-add pos dir_to_try)))
      (cons (vec2-add pos dir_to_try) dir_to_try)))
  (if next-pos-dir
      (go network (car next-pos-dir) (cdr next-pos-dir) (add1 steps))
      (add1 steps)))

(define (both-parts network)
  (define steps (go network (network-entrance network) (vec2 0 1) 0))
  (displayln "")
  (displayln steps))

(both-parts network)
