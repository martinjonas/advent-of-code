filename = (length(ARGS) == 0) ? "input" : ARGS[1]
const input = readlines(filename)

function is_visible(grid, row, col)
    nrows = length(grid)
    ncols = length(grid[1])
    height = grid[row][col]

    all(grid[r][col] < height for r in 1:row-1) ||
        all(grid[r][col] < height for r in row+1:nrows) ||
        all(grid[row][c] < height for c in 1:col-1) ||
        all(grid[row][c] < height for c in col+1:ncols)
end

function part1(grid)
    nrows = length(grid)
    ncols = length(grid[1])

    sum(is_visible(grid, row, col) for row ∈ 1:nrows for col ∈ 1:ncols)
end

function first_or_length(A)
    res = 0
    for x ∈ A
        res += 1
        x && break
    end
    res
end

function scenic_score(grid, row, col)
    nrows = length(grid)
    ncols = length(grid[1])
    height = grid[row][col]

    first_or_length(grid[r][col] >= height for r in row-1:-1:1) *
        first_or_length(grid[r][col] >= height for r in row+1:nrows) *
        first_or_length(grid[row][c] >= height for c in col-1:-1:1) *
        first_or_length(grid[row][c] >= height for c in col+1:ncols)
end


function part2(grid)
    nrows = length(grid)
    ncols = length(grid[1])

    maximum(scenic_score(grid, row, col) for row ∈ 1:nrows for col ∈ 1:ncols)
end

input |> part1 |> println
input |> part2 |> println
