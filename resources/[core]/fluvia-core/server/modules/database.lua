-- Wrappers oxmysql utilisés par fluvia-core uniquement.
-- Les autres ressources utilisent @oxmysql/lib/MySQL.lua directement.

DB = {}

function DB.FetchScalar(query, params)
    return MySQL.scalar.await(query, params or {})
end

function DB.Fetch(query, params)
    return MySQL.query.await(query, params or {})
end

function DB.Execute(query, params)
    return MySQL.update.await(query, params or {})
end

function DB.Insert(query, params)
    return MySQL.insert.await(query, params or {})
end
