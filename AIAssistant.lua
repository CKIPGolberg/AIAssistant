-- Запрос к Gemini API с выводом точной ошибки
local function GetAIResponse(prompt)
    local lower = prompt:lower()
    
    local targetName = lower:match("подойди%s+к%s+(.+)") or lower:match("иди%s+к%s+(.+)")
    if targetName then
        return ApproachPlayer(targetName)
    end
    
    if lower == "/help" then
        return "Команды:\n- Любой вопрос (ответит Gemini)\n- 'подойди к [ник]' (идти к игроку)"
    end

    local p1 = "AQ.Ab8RN6Llx4HhrHNeBp6x7"
    local p2 = "F6tk6eVWd5XvDVw-VVHHJymAgqz1A"
    local apiKey = p1 .. p2
    
    local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" .. apiKey
    
    local requestData = {
        contents = {
            {
                parts = {
                    { text = "Ты игровой помощник в Roblox. Отвечай кратко, по делу и на русском языке: " .. prompt }
                }
            }
        }
    }
    
    local success, response = pcall(function()
        local req = (http_request or request or HttpService.RequestAsync)
        return req({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(requestData)
        })
    end)
    
    if not success then
        return "Ошибка выполнения pcall: " .. tostring(response)
    end
    
    if response then
        local bodyText = response.Body or response.Data
        local statusCode = response.StatusCode or response.Status
        
        -- Если статус не 200 (успех), покажем текст ошибки от сервера
        if statusCode and statusCode ~= 200 then
            return "Ошибка сервера (" .. tostring(statusCode) .. "): " .. tostring(bodyText)
        end
        
        if bodyText then
            local successDecode, data = pcall(function()
                return HttpService:JSONDecode(bodyText)
            end)
            if successDecode and data then
                if data.error then
                    return "Ошибка от Google: " .. tostring(data.error.message or "неизвестно")
                end
                if data.candidates and data.candidates[1] then
                    local parts = data.candidates[1].content.parts
                    if parts and parts[1] then
                        return parts[1].text
                    end
                end
            else
                return "Ответ не JSON: " .. tostring(bodyText)
            end
        end
    end
    
    return "Пустой ответ от сервера."
end
