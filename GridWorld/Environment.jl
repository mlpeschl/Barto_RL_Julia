mutable struct GridWorld

    #################################
    #6x10 Fields
    #------------------------------
    # 1  2  3  4  5  6  7  8  9  10
    # 11 12 13 14 15 16 17 18 19 20
    # 21 22 23 24 25 26 27 28 29 30
    # 31 32 33 34 35 36 37 38 39 40
    # 41 42 43 44 45 46 47 48 49 50
    # 51 52 53 54 55 56 57 58 59 60
    #-------------------------------

    start::Int64
    goal::Int64
    position::Int64
    blocks::Array{Int64,1}

    function GridWorld(start = 54, goal = 10, position = 54, blocks = collect(31:39))
        new(start,goal,position,blocks)
    end
end


function move(g::GridWorld,dir::Int64)

    # up = 1 , right = 2, down = 3, left = 4
    # Calculate resultant next state


    if dir == 1
        (g.position - 10 <= 0) ? tmp_pos =  g.position : tmp_pos = g.position - 10
    elseif dir == 2
        (g.position % 10 == 0) ? tmp_pos = g.position : tmp_pos = g.position + 1
    elseif dir == 3
        (g.position + 10 > 60) ? tmp_pos = g.position : tmp_pos = g.position + 10
    elseif dir == 4
        (g.position % 10 == 1) ? tmp_pos = g.position : tmp_pos = g.position -1
    end

    if !(tmp_pos in g.blocks)
        g.position = tmp_pos
    end

end

function action(g::GridWorld, act::Int64)
    #Take action, get (Reward, isDone)
    move(g,act)

    if g.position == g.goal
        g.position = g.start   #reset environment
        return (1,true)

    else
        return (0,false)
    end
end
