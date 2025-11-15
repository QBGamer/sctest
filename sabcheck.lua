task.spawn(function()
    repeat task.wait() until game:IsLoaded()
    repeat task.wait() until game.Players.LocalPlayer
    local player = game.Players.LocalPlayer
    repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    repeat task.wait() until game.ReplicatedStorage:FindFirstChild("Packages") and game.ReplicatedStorage.Packages:FindFirstChild("Synchronizer")
    task.wait(5)

    local HttpService = game:GetService("HttpService")
    local Synchronizer = require(game.ReplicatedStorage.Packages.Synchronizer)
    local playerSync = Synchronizer:Get(player)
    local plrAnimalPodiums = playerSync:Get("AnimalPodiums")

    -- === File config ===
    local jsonFile = "BrainrotData_AllAccounts.json"
    local summaryFile = "BrainrotData_Summary.txt"
    local data = {}

    -- === Đọc JSON cũ (nếu có) ===
    if isfile(jsonFile) then
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(jsonFile))
        end)
        if ok and type(decoded) == "table" then
            data = decoded
        else
            data = {}
        end
    end

    -- === Tạo bảng riêng cho account nếu chưa có ===
    if not data[player.Name] then
        data[player.Name] = {}
    end

    -- === Gom dữ liệu từ podiums ===
    for _, v in pairs(plrAnimalPodiums or {}) do
        if v then
            local category

            local hasTraits = v.Traits and #v.Traits > 0
            local hasMutation = v.Mutation and v.Mutation ~= ""

            if hasTraits and hasMutation then
                category = `{v.Mutation} ({table.concat(v.Traits, ", ")})`
            elseif hasTraits then
                category = table.concat(v.Traits, ", ")
            elseif hasMutation then
                category = v.Mutation
            elseif v.Index then
                category = v.Index:gsub("Secret ", "")
            else
                category = "Unknown"
            end

            if category then
                category = category:gsub("^%l", string.upper)
                data[player.Name][category] = (data[player.Name][category] or 0) + 1
            end
        end
    end

    -- === Ghi vào file JSON ===
    writefile(jsonFile, HttpService:JSONEncode(data))

    -- === Ghi file TXT tổng hợp dễ đọc ===
    local lines = {}
    for plrName, pets in pairs(data) do
        local parts = {}
        for name, count in pairs(pets) do
            table.insert(parts, "X" .. count .. " " .. name)
        end
        table.insert(lines, plrName .. " : " .. table.concat(parts, ", "))
    end
    writefile(summaryFile, table.concat(lines, "\n"))

    -- === Thông báo console ===
    print("-----")
    print("✅ Đã tổng hợp & lưu Brainrot cho:", player.Name)
    print("💾 Dữ liệu JSON:", jsonFile)
    print("📝 Dữ liệu tóm tắt:", summaryFile)
    print("-----")
end)
