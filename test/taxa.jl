using Test, OTrees

function test_taxon_set_properties(ts, taxon_indices, taxon_names)
    n = length(taxon_names)
    @test length(ts) == n
    @test length(ts.taxa) == n
    @test length(ts.names) == n

    for (taxon_index, taxon_name) in zip(taxon_indices, taxon_names)
        taxon = ts[taxon_name]
        @test ts[taxon_index] === taxon
        @test taxon.id == taxon_index
        @test taxon.name == taxon_name
    end

    return nothing
end

@testset "`Taxon` and `TaxonSet`" begin
    taxon_names = ["Aus", "Bus", "Cus", "Aus"]
    taxon_indices = 1:4

    taxon_names[4] = "Gus"

    ts = TaxonSet(taxon_names)

    test_taxon_set_properties(ts, taxon_indices, taxon_names)

    taxon_names[4] = "Dus"
    setname!(ts, "Gus", "Dus")

    test_taxon_set_properties(ts, taxon_indices, taxon_names)
    
    delete!(ts, "Bus")
    deleteat!(taxon_names, 2)
    taxon_indices = 1:3
    
    test_taxon_set_properties(ts, taxon_indices, taxon_names)
    
    push!(taxon_names, "Eus", "Fus", "Gus")
    taxon_indices = 1:6
    add!(ts, taxon_names[4:6])
    
    test_taxon_set_properties(ts, taxon_indices, taxon_names)
end
