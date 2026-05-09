-- Helper de vérification de permission pour fluvia-admin
function CheckPerm(src, node)
    return exports['fluvia-core']:HasPermission(src, node)
end
