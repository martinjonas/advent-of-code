#lang racket

(define input-file "input")
(define input (file->lines input-file))

(define (add-line-to-graph line graph)
  (match-define (list node succ-string) (string-split line " <-> "))
  (hash-set graph node (string-split succ-string ", ")))

(define (input->graph input)
  (foldl add-line-to-graph (make-immutable-hash) input))

(define (dfs graph current seen)
  (cond
    [(set-member? seen current) seen]
    [else
     (define successors (hash-ref graph current))
      (foldl (curry dfs graph) (set-add seen current) successors)]))

(define (get-reachable graph start)
  (dfs graph start (set)))

(define (count-unseen-connected-components graph unseen acc)
  (cond
    [(set-empty? unseen) acc]
    [else
     (define some-scc (get-reachable graph (set-first unseen)))
     (count-unseen-connected-components graph (set-subtract unseen some-scc) (add1 acc))]))

(define (count-connected-components graph)
  (define unseen (list->set (hash-keys graph)))
  (count-unseen-connected-components graph unseen 0))

(define (part1 input)
  (set-count (get-reachable (input->graph input) "0")))

(define (part2 input)
  (count-connected-components (input->graph input)))

(part1 input)
(part2 input)
