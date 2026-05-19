-- Target Sizing Module
-- Handles adjustment of NPC target bounds for visibility/testing

local TargetSizing = {}

TargetSizing.originalSizes = {} -- Storage for original sizes to restore them later

-- Adjusts the NPC target bounds
function TargetSizing:applyTargetSizing(model, part, config)
    -- Track original sizes by the specific part instance instead of the model
    if not self.originalSizes[part] then 
        self.originalSizes[part] = part.Size 
    end
    
    if part.Size ~= config.TARGET_BOX_SIZE then
        part.Size = config.TARGET_BOX_SIZE
    end
    local targetTransparency = config.showTargetBox and 0.85 or 1
    if part.Transparency ~= targetTransparency then
        part.Transparency = targetTransparency 
    end
    if not part.CanCollide then
        part.CanCollide = true
    end
end

-- Restores target bounds to their normal size
function TargetSizing:restoreOriginalSize()
    for part, originalSize in pairs(self.originalSizes) do
        if part and part.Parent then
            pcall(function()
                part.Size = originalSize
                part.Transparency = 0 -- Revert head back to visible texturing
                part.CanCollide = true
            end)
        end
    end
    self.originalSizes = {}
end

-- Updates target bounds for all NPCs based on config
function TargetSizing:updateAllTargets(npcManager, config)
    if not config.sizingEnabled then
        if next(self.originalSizes) then
            self:cleanup(npcManager)
        end
        return
    end
    
    for model, data in pairs(npcManager:getActiveNPCs()) do
        -- Find the NPC's actual Head part recursively
        local headPart = model:FindFirstChild("Head", true)
        
        if headPart and headPart:IsA("BasePart") then
            -- Expand the Head instead of the torso root
            self:applyTargetSizing(model, headPart, config)
        elseif data.root then
            -- Fallback to default body root if the head can't be found
            self:applyTargetSizing(model, data.root, config)
        end
    end
end

-- Cleanup all adjusted target bounds
function TargetSizing:cleanup(npcManager)
    self:restoreOriginalSize()
end

return TargetSizing
