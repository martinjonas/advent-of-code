#lang racket

(require racket/hash)

(define file-name "input")

(define input (file->lines file-name))

(struct program (name weight successors) #:transparent)

(define (parse-program s)
  (match-define (list _ name weight _ successors) (regexp-match #px"(\\w+) \\((\\d+)\\)( -> (.+))?" s))
  (program name (string->number weight) (if successors (string-split successors ", ") #f)))

(define programs (make-hash))
(for ([line input])
  (define program (parse-program line))
  (hash-set! programs (program-name program) program))

(define with-successors (filter program-successors (hash-values programs)))
(define with-predecessors (mutable-set))
(for-each (λ (program) (set-union! with-predecessors (list->set (program-successors program)))) with-successors)

(define main (findf (λ (name) (not (set-member? with-predecessors name))) (hash-keys programs)))
(displayln main)

(define (compute-weights current)
  (match-define (program name weight successors) (hash-ref programs current))
  (match successors
    [#f (make-immutable-hash (list (cons name weight)))]
    [xs
     (define result (apply hash-union (map compute-weights xs)))
     (hash-set result name (foldl + weight (map (curry hash-ref result) successors)))]))

(define weights (compute-weights main))

(define (identify-wrong current difference)
  (match-define (program name weight successors) (hash-ref programs current))
  (match successors
    [#f (values name weight difference)]
    [xs
     (define successor-weights (group-by cdr (map (λ (name) (cons name (hash-ref weights name))) xs)))
     (define one-group (findf (λ (group) (= 1 (length group))) successor-weights))
     (if one-group
         (let ([correct-value (cdr (first (findf (λ (group) (< 1 (length group))) successor-weights)))]
               [to-correct (first one-group)])
           (identify-wrong (car to-correct) (- correct-value (cdr to-correct))))
         (+ weight difference))]))

(identify-wrong main #f)

