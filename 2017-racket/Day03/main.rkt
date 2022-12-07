#lang racket

(require rackunit)

(define (compute-layer n)
  (exact-floor (/ (ceiling (sqrt n)) 2)))

(check-equal? (compute-layer 1) 0)
(check-equal? (compute-layer 2) 1)
(check-equal? (compute-layer 12) 2)
(check-equal? (compute-layer 9) 1)

(struct pos (x y) #:transparent)

(define (compute-offset n layer)
  (define side (+ (* layer 2) 1))
  (define side-m-1 (- side 1))
  (define layer-root (* side side))
  (define distance (- layer-root n))
  (define distance-mod (if (= side 1) 0 (modulo distance (- side 1))))
  (cond
    [(< distance side) (values (- distance) 0)]
    [(< distance (* 2 side-m-1)) (values (- side-m-1) distance-mod)]
    [(< distance (* 3 side-m-1)) (values (- distance-mod side-m-1) side-m-1)]
    [else (values 0 (- side-m-1 distance-mod))]))

(define (compute-position n)
  (define layer (compute-layer n))
  (define-values (off-x off-y) (compute-offset n layer))
  (pos (+ off-x layer) (- off-y layer)))

(define (part1 n)
  (match-define (pos x y) (compute-position n))
  (+ (abs x) (abs y)))

(check-equal? (part1 1) 0)
(check-equal? (part1 12) 3)
(check-equal? (part1 23) 2)
(check-equal? (part1 1024) 31)

(part1 368078)

(define (get-neighbors p)
  (match-define (pos x y) p)
  (for*/list ([dx `(-1 0 1)]
              [dy `(-1 0 1)])
    (pos (+ x dx) (+ y dy))))

(define (sum-neighbors h p)
  (for/sum ([n (get-neighbors p)])
    (hash-ref h n 0)))

(define (part2 limit)
  (define map-hash (make-hash))
  (hash-set! map-hash (pos 0 0) 1)
  (for/or ([n (in-naturals 1)])
    (define p (compute-position n))
    (define new-val (sum-neighbors map-hash p))
    (hash-set! map-hash p new-val)
    (if (> new-val limit) new-val #f)
    ))

(part2 368078)
