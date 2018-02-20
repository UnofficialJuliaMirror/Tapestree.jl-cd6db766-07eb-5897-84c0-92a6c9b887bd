#=

Proposal functions for joint
Biogeographic competition model

Ignacio Quintero Mächler

t(-_-t)

May 16 2017

=#




"""
    upnode!(λ::Array{Float64,1}, triad::Vector{Int64}, Y::Array{Int64,3}, bridx_a::Vector{Vector{Vector{Int64}}}, brδt::Vector{Vector{Float64}}, brl::Vector{Float64}, brs::Array{Int64,3}, narea::Int64, nedge::Int64)

Update node and incident branches using discrete 
Data Augmentation for all areas.
"""
function upnode!(λ1     ::Float64,
                 λ0     ::Float64,
                 triad  ::Array{Int64,1},
                 Y      ::Array{Int64,3},
                 bridx_a::Array{Array{UnitRange{Int64},1},1},
                 brδt   ::Vector{Vector{Float64}},
                 brl    ::Vector{Float64},
                 brs    ::Array{Int64,3},
                 narea  ::Int64,
                 nedge  ::Int64)

  @inbounds begin
   
    # define branch triad
    pr, d1, d2 = triad

    # sample
    samplenode!(λ1, λ0, pr, d1, d2, brs, brl, narea)

    # save extinct
    while sum(brs[pr,2,:]) == 0
      samplenode!(λ1, λ0, pr, d1, d2, brs, brl, narea)
    end

    # sample a consistent history
    createhists!(λ1, λ0, Y, pr, d1, d2, brs, brδt, bridx_a, narea, nedge)
  
    # save extinct
    # ntries = 1

    while ifextY(Y,  triad, narea, bridx_a)
      createhists!(λ1, λ0, Y, pr, d1, d2, brs, brδt, bridx_a, narea, nedge)
      
      # ntries += 1
      # if ntries > 100_000_000 
      #   warn("iid model sampling is very inefficient")
        
      #   # @show Y[bridx_a[1][pr]]
      #   # @show Y[bridx_a[2][pr]]
      #   # @show Y[bridx_a[3][pr]]

      #   # @show Y[bridx_a[1][d1]]
      #   # @show Y[bridx_a[2][d1]]
      #   # @show Y[bridx_a[3][d1]]
      
      #   # @show Y[bridx_a[1][d2]]
      #   # @show Y[bridx_a[2][d2]]
      #   # @show Y[bridx_a[3][d2]]

      # end
    end
  end

  return nothing
end






"""
    upnode!(λ::Array{Float64,1}, ω1::Float64, ω0::Float64, avg_Δx::Array{Array{Float64,1},1}, triad::Array{Int64,1}, Y::Array{Int64,3}, bridx_a::Vector{Vector{Vector{Int64}}}, brδt::Vector{Vector{Float64}}, brl::Vector{Float64}, brs::Array{Int64,3}, narea::Int64, nedge::Int64)

Update node and incident branches using discrete 
Data Augmentation for all areas with independent 
proposals taking into account `Δx` and `ω1` & `ω0`.
"""
function upnode!(λ1     ::Float64,
                 λ0     ::Float64,
                 ω1     ::Float64,
                 ω0     ::Float64,
                 avg_Δx ::Array{Float64,2},
                 triad  ::Array{Int64,1},
                 Y      ::Array{Int64,3},
                 bridx_a::Array{Array{UnitRange{Int64},1},1},
                 brδt   ::Vector{Vector{Float64}},
                 brl    ::Vector{Float64},
                 brs    ::Array{Int64,3},
                 narea  ::Int64,
                 nedge  ::Int64)

  @inbounds begin
   
    # define branch triad
    pr, d1, d2 = triad

    # sample
    samplenode!(λ1, λ0, ω1, ω0, avg_Δx, pr, d1, d2, brs, brl, narea)

    # save extinct
    while sum(brs[pr,2,:]) == 0
       samplenode!(λ1, λ0, ω1, ω0, avg_Δx, pr, d1, d2, brs, brl, narea)
    end


    # sample a consistent history
    createhists!(λ1, λ0, ω1, ω0, avg_Δx, 
                 Y, pr, d1, d2, brs, brδt, bridx_a, narea, nedge)

    # ntries = 1

    # save extinct
    while ifextY(Y, triad, narea, bridx_a)
      createhists!(λ1, λ0, ω1, ω0, avg_Δx, 
                   Y, pr, d1, d2, brs, brδt, bridx_a, narea, nedge)

      # ntries += 1
      # if ntries > 100_000_000
      #   #warn("branch average iid sampling is very inefficient") 
      #   # @show λ[1]*exp(ω1*avg_Δx[pr,1]), λ[1]*exp(ω1*avg_Δx[pr,2]), λ[1]*exp(ω1*avg_Δx[pr,3])
      #   # @show λ[1]*exp(ω1*avg_Δx[d1,1]), λ[1]*exp(ω1*avg_Δx[d1,2]), λ[1]*exp(ω1*avg_Δx[d1,3])
      #   # @show λ[1]*exp(ω1*avg_Δx[d2,2]), λ[1]*exp(ω1*avg_Δx[d2,2]), λ[1]*exp(ω1*avg_Δx[d2,3])
      #   # @show λ[2]*exp(ω0*avg_Δx[pr,1]), λ[2]*exp(ω0*avg_Δx[pr,2]), λ[2]*exp(ω0*avg_Δx[pr,3])
      #   # @show λ[2]*exp(ω0*avg_Δx[d1,1]), λ[2]*exp(ω0*avg_Δx[d1,2]), λ[2]*exp(ω0*avg_Δx[d1,3])
      #   # @show λ[2]*exp(ω0*avg_Δx[d2,1]), λ[2]*exp(ω0*avg_Δx[d2,2]), λ[2]*exp(ω0*avg_Δx[d2,3])

      #   # @show Y[bridx_a[1][pr]]
      #   # @show Y[bridx_a[2][pr]]
      #   # @show Y[bridx_a[3][pr]]

      #   # @show Y[bridx_a[1][d1]]
      #   # @show Y[bridx_a[2][d1]]
      #   # @show Y[bridx_a[3][d1]]
      
      #   # @show Y[bridx_a[1][d2]]
      #   # @show Y[bridx_a[2][d2]]
      #   # @show Y[bridx_a[3][d2]]

      # end
    end
  end

  return nothing
end





"""
    ifextY(Y::Array{Int64,3}, triad::Array{Int64,1}, narea::Int64, bridx_a::Array{Array{Array{Int64,1},1},1})

Return `true` if at some point the species
goes extinct and/or more than one change is 
observed after some **δt**, otherwise returns `false`.
"""
function ifextY(Y      ::Array{Int64,3},
                triad  ::Array{Int64,1},
                narea  ::Int64,
                bridx_a::Array{Array{UnitRange{Int64},1},1})

  @inbounds begin

    for k in triad

      for i = Base.OneTo((length(bridx_a[1][k]::UnitRange{Int64})-1)::Int64)
        s_e = 0::Int64            # count current areas
        s_c = 0::Int64            # count area changes

        for j = Base.OneTo(narea)
          s_e += Y[bridx_a[j][k][i]]::Int64
          if Y[bridx_a[j][k][i]]::Int64 != Y[bridx_a[j][k][i+1]]::Int64
            s_c += 1::Int64
          end
        end

        if s_e::Int64 == 0::Int64 || s_c::Int64 > 1::Int64
          return true::Bool
        end
      end
    end

  end

  return false::Bool
end





"""
    createhists!(λ::Array{Float64,1}, Y::Array{Int64,3}, pr::Int64, d1::Int64, d2::Int64, brs::Array{Int64,3}, brδt::Array{Array{Float64,1},1}, bridx_a::Array{Array{Array{Int64,1},1},1}, narea::Int64)

Create bit histories for all areas for the branch trio.
"""
function createhists!(λ1     ::Float64,
                      λ0     ::Float64,
                      Y      ::Array{Int64,3},
                      pr     ::Int64,
                      d1     ::Int64,
                      d2     ::Int64,
                      brs    ::Array{Int64,3},
                      brδt   ::Array{Array{Float64,1},1},
                      bridx_a::Array{Array{UnitRange{Int64},1},1},
                      narea  ::Int64,
                      nedge  ::Int64)

  @inbounds begin

    for j = Base.OneTo(narea)

      # set new node in Y
      setindex!(Y, brs[pr,2,j], bridx_a[j][pr][end])
      setindex!(Y, brs[pr,2,j], bridx_a[j][d1][1])
      setindex!(Y, brs[pr,2,j], bridx_a[j][d2][1])

      if pr < nedge
        # for parent branch
        bit_rejsam!(Y, bridx_a[j][pr], brs[pr,2,j], λ1, λ0, brδt[pr])
      end

      # for daughter branch 1
      bit_rejsam!(Y, bridx_a[j][d1], brs[d1,2,j], λ1, λ0, brδt[d1])

      # for daughter branch 2
      bit_rejsam!(Y, bridx_a[j][d2], brs[d2,2,j], λ1, λ0, brδt[d2])

    end
  end

  return nothing
end





"""
    createhists!(λ::Array{Float64,1}, Y::Array{Int64,3}, pr::Int64, d1::Int64, d2::Int64, brs::Array{Int64,3}, brδt::Array{Array{Float64,1},1}, bridx_a::Array{Array{Array{Int64,1},1},1}, narea::Int64)

Create bit histories for all areas for the branch 
trio taking into account `Δx` and `ω1` & `ω0`.
"""
function createhists!(λ1     ::Float64,
                      λ0     ::Float64,
                      ω1     ::Float64,  
                      ω0     ::Float64, 
                      avg_Δx ::Array{Float64,2},
                      Y      ::Array{Int64,3},
                      pr     ::Int64,
                      d1     ::Int64,
                      d2     ::Int64,
                      brs    ::Array{Int64,3},
                      brδt   ::Array{Array{Float64,1},1},
                      bridx_a::Array{Array{UnitRange{Int64},1},1},
                      narea  ::Int64,
                      nedge  ::Int64)

  @inbounds begin

    for j = Base.OneTo(narea)

      # set new node in Y
      setindex!(Y, brs[pr,2,j], bridx_a[j][pr][end])
      setindex!(Y, brs[pr,2,j], bridx_a[j][d1][1])
      setindex!(Y, brs[pr,2,j], bridx_a[j][d2][1])

      if pr < nedge
        # for parent branch
        bit_rejsam!(Y, bridx_a[j][pr], brs[pr,2,j], 
                    λ1, λ0, ω1, ω0, avg_Δx[pr,j], brδt[pr])
      end

      # for daughter branch 1
      bit_rejsam!(Y, bridx_a[j][d1], brs[d1,2,j], 
                  λ1, λ0, ω1, ω0, avg_Δx[d1,j], brδt[d1])

      # for daughter branch 2
      bit_rejsam!(Y, bridx_a[j][d2], brs[d2,2,j], 
                  λ1, λ0, ω1, ω0, avg_Δx[d2,j], brδt[d2])

    end

  end
  
  return nothing
end





"""
    samplenode!(λ::Array{Float64,1}, pr::Int64, d1::Int64, d2::Int64, brs::Array{Int64,3}, brl::Array{Float64,1}, narea::Int64)

Sample one internal node according to 
mutual-independence model transition probabilities.
"""
function samplenode!(λ1   ::Float64, 
                     λ0   ::Float64,
                     pr   ::Int64,
                     d1   ::Int64,
                     d2   ::Int64,
                     brs  ::Array{Int64,3},
                     brl  ::Array{Float64,1},
                     narea::Int64)
  @inbounds begin

    for j = Base.OneTo(narea)

      # transition probabilities for the trio
      ppr_1, ppr_2 = 
        Ptrfast_start(λ1, λ0, brl[pr], brs[pr,1,j])
      pd1_1, pd1_2 = 
        Ptrfast_end(  λ1, λ0, brl[d1], brs[d1,2,j])
      pd2_1, pd2_2 = 
        Ptrfast_end(  λ1, λ0, brl[d2], brs[d2,2,j])

      # normalize probability
      tp = normlize(*(ppr_1, pd1_1, pd2_1),
                    *(ppr_2, pd1_2, pd2_2))::Float64

      # sample the node's character
      brs[pr,2,j] = brs[d1,1,j] = brs[d2,1,j] = coinsamp(tp)::Int64
    end
  end

  return nothing
end





"""
    samplenode!(λ::Array{Float64,1}, pr::Int64, d1::Int64, d2::Int64, brs::Array{Int64,3}, brl::Array{Float64,1}, narea::Int64)

Sample one internal node according to 
mutual-independence model transition probabilities
taking into account `Δx` and `ω1` & `ω0`.
"""
function samplenode!(λ1    ::Float64, 
                     λ0    ::Float64,
                     ω1    ::Float64,
                     ω0    ::Float64,
                     avg_Δx::Array{Float64,2},
                     pr    ::Int64,
                     d1    ::Int64,
                     d2    ::Int64,
                     brs   ::Array{Int64,3},
                     brl   ::Array{Float64,1},
                     narea ::Int64)
  @inbounds begin

    for j = Base.OneTo(narea)

      # transition probabilities for the trio
      ppr_1, ppr_2 = 
        Ptrfast_start(λ1, λ0, ω1, ω0, avg_Δx[pr,j], brl[pr], brs[pr,1,j])
      pd1_1, pd1_2 = 
        Ptrfast_end(  λ1, λ0, ω1, ω0, avg_Δx[d1,j], brl[d1], brs[d1,2,j])
      pd2_1, pd2_2 = 
        Ptrfast_end(  λ1, λ0, ω1, ω0, avg_Δx[d2,j], brl[d2], brs[d2,2,j])

      # normalize probabilitye
      tp = normlize(*(ppr_1, pd1_1, pd2_1),
                    *(ppr_2, pd1_2, pd2_2))::Float64

      # sample the node's character
      brs[pr,2,j] = brs[d1,1,j] = brs[d2,1,j] = coinsamp(tp)::Int64
    end
  end

  return nothing
end





"""
    upstem(λ::Array{Float64,1}, idx::Int64, brs::Array{Int64,3}, brl::Vector{Float64}, narea::Int64)

Update stem branch using continuous Data Augmentation.
"""
function upstem(λ1   ::Float64, 
                λ0   ::Float64,
                idx  ::Int64,
                brs  ::Array{Int64,3}, 
                brl  ::Vector{Float64},
                narea::Int64)

  @inbounds begin
    
    for j = Base.OneTo(narea)
      # transition probabilities
      p1::Tuple{Float64,Float64} = 
        Ptrfast_end(λ1, λ0, brl[idx], brs[idx,2,j])

      # sample the stem node character
      brs[idx,1,j] = coinsamp(normlize(p1[1],p1[2]))
    end

    while sum(brs[idx,1,:]) < 1
      for j = Base.OneTo(narea)
        # transition probabilities
        p1::Tuple{Float64,Float64} = 
          Ptrfast_end(λ1, λ0, brl[idx], brs[idx,2,j])

        # sample the stem node character
        brs[idx,1,j] = coinsamp(normlize(p1[1],p1[2]))
      end
    end

    # sample new history for stem branch
    return br_samp(brs[idx,1,:], brs[idx,2,:], λ1, λ0, brl[idx], narea)

  end
end





"""
    upbranch!(λ1     ::Float64,
              λ0     ::Float64,
              ω1     ::Float64,
              ω0     ::Float64,
              avg_Δx ::Array{Float64,2},
              br     ::Int64,
              Y      ::Array{Int64,3},
              bridx_a::Array{Array{UnitRange{Int64},1},1},
              brδt   ::Vector{Vector{Float64}},
              brl    ::Vector{Float64},
              brs    ::Array{Int64,3},
              narea  ::Int64,
              nedge  ::Int64)

Update one branch using discrete Data Augmentation 
for all areas with independent 
proposals taking into account `Δx` and `ω1` & `ω0`.
"""
function upbranch!(λ1     ::Float64,
                   λ0     ::Float64,
                   ω1     ::Float64,
                   ω0     ::Float64,
                   avg_Δx ::Array{Float64,2},
                   br     ::Int64,
                   Y      ::Array{Int64,3},
                   bridx_a::Array{Array{UnitRange{Int64},1},1},
                   brδt   ::Vector{Vector{Float64}},
                   brl    ::Vector{Float64},
                   brs    ::Array{Int64,3},
                   narea  ::Int64,
                   nedge  ::Int64)

  @inbounds begin

    # sample a consistent history
    createhists!(λ1, λ0, ω1, ω0, avg_Δx, 
                 Y, br, brs, brδt, bridx_a, narea)

    # check if extinct
    while ifextY(Y, triad, narea, bridx_a)
      createhists!(λ1, λ0, ω1, ω0, avg_Δx, 
                   Y, br, brs, brδt, bridx_a, narea)
    end
  end

  return nothing
end





"""
    createhists!(λ1     ::Float64,
                 λ0     ::Float64,
                 ω1     ::Float64,  
                 ω0     ::Float64, 
                 avg_Δx ::Array{Float64,2},
                 Y      ::Array{Int64,3},
                 br     ::Int64,
                 brs    ::Array{Int64,3},
                 brδt   ::Array{Array{Float64,1},1},
                 bridx_a::Array{Array{UnitRange{Int64},1},1},
                 narea  ::Int64)

Create bit histories for all areas for one single branch 
taking into account `Δx` and `ω1` & `ω0`, with random number of
areas updated.
"""
function createhists!(λ1     ::Float64,
                      λ0     ::Float64,
                      ω1     ::Float64,  
                      ω0     ::Float64, 
                      avg_Δx ::Array{Float64,2},
                      Y      ::Array{Int64,3},
                      br     ::Int64,
                      brs    ::Array{Int64,3},
                      brδt   ::Array{Array{Float64,1},1},
                      bridx_a::Array{Array{UnitRange{Int64},1},1},
                      narea  ::Int64)

  @inbounds begin
    for j = randsubseq(Base.OneTo(narea),0.5)
      bit_rejsam!(Y, bridx_a[j][br], brs[br,2,j], 
                  λ1, λ0, ω1, ω0, avg_Δx[br,j], brδt[br])
    end
  end

  return nothing
end





"""
    ifextY(Y      ::Array{Int64,3},
           br     ::Int64,
           narea  ::Int64,
           bridx_a::Array{Array{UnitRange{Int64},1},1})

Return `true` if at some point the species
goes extinct and/or more than one change is 
observed after some **δt**, otherwise returns `false`. 
This specific method is for single branch updates.
"""
function ifextY(Y      ::Array{Int64,3},
                br     ::Int64,
                narea  ::Int64,
                bridx_a::Array{Array{UnitRange{Int64},1},1})

  @inbounds begin

    for i = Base.OneTo((length(bridx_a[1][br]::UnitRange{Int64})-1)::Int64)
      s_e = 0::Int64            # count current areas
      s_c = 0::Int64            # count area changes

      for j = Base.OneTo(narea)
        s_e += Y[bridx_a[j][br][i]]::Int64
        if Y[bridx_a[j][br][i]]::Int64 != Y[bridx_a[j][br][i+1]]::Int64
          s_c += 1::Int64
        end
      end

      if s_e::Int64 == 0::Int64 || s_c::Int64 > 1::Int64
        return true::Bool
      end
    end

  end

  return false::Bool
end







#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# X proposal functions
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


"""
    upbranchX!(j    ::Int64, 
               X    ::Array{Float64,2}, 
               bridx::Array{UnitRange{Int64},1},
               brδt ::Array{Array{Float64,1},1}, 
               σ²c  ::Float64)

Update a branch j in X using a Brownian bridge.
"""
function upbranchX!(j    ::Int64, 
                    X    ::Array{Float64,2}, 
                    bridx::Array{UnitRange{Int64},1},
                    brδt ::Array{Array{Float64,1},1}, 
                    σ²   ::Float64)

  @inbounds bbX!(X, bridx[j], brδt[j], σ²)
end





"""
    bbX!(x::Array{Float64,1}, t::::Array{Float64,1}, σ::Float64)

Brownian bridge simulation function for updating a branch in X in place.
"""
function bbX!(X  ::Array{Float64,2}, 
              idx::UnitRange,
              t  ::Array{Float64,1},  
              σ² ::Float64)

  @inbounds begin

    xf::Float64 = X[idx[end]]

    for i = Base.OneTo(endof(t)-1)
      X[idx[i+1]] = (X[idx[i]] + randn()*sqrt((t[i+1] - t[i])*σ²))::Float64
    end

    for i = Base.OneTo(endof(t))
      X[idx[i]] = (X[idx[i]] - t[i]/t[end] * (X[idx[end]] - xf))::Float64
    end
  end

  return nothing
end




