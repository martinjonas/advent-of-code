#lang racket

(define input-file "input")
(define lines (file->lines input-file))
(define-values (player1Str player2Str) (splitf-at lines non-empty-string?))

(define stack1 (filter-map string->number player1Str))
(define stack2 (filter-map string->number player2Str))

(define (score stack)
  (for/sum ([card (reverse stack)] [i (in-naturals)]) (* card (+ i 1))))

(define (step firstWins h1 h2 t1 t2)
  (if firstWins
      (cons (append t1 (list h1 h2)) t2)
      (cons t1 (append t2 (list h2 h1)))))

(struct result (winner stack))

(define (play recursive stack1 stack2 seen)
  (let ((key (cons stack1 stack2)))
    (if (set-member? seen key)
        (result 'player1 stack1)
        (match (cons stack1 stack2)
          [(cons '() _) (result 'player2 stack2)]
          [(cons _ '()) (result 'player1 stack1)]
          [(cons (cons h1 t1) (cons h2 t2))
           (let ([first-wins (if (and recursive (>= (length t1) h1) (>= (length t2) h2))
                                 (eq? 'player1 (result-winner (play recursive (take t1 h1) (take t2 h2) (set))))
                                 (>= h1 h2))])
             (match-let ([(cons new-stack1 new-stack2) (step first-wins h1 h2 t1 t2)])
                        (play recursive new-stack1 new-stack2 (set-add seen key))))]))))

(printf "Part 1: ~a\n" (score (result-stack (play #f stack1 stack2 (set)))))
(printf "Part 2: ~a\n" (score (result-stack (play #t stack1 stack2 (set)))))
