---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by seletz.
--- DateTime: 18.02.18 12:23
---

Director = Object:extend()

local function chanceList(...)
    return {
        chance_list = {},
        chance_definitions = {...},
        next = function(self)
            if #self.chance_list == 0 then
                for _, chance_definition in ipairs(self.chance_definitions) do
                    for i = 1, chance_definition[2] do
                        table.insert(self.chance_list, chance_definition[1])
                    end
                end
            end
            return table.remove(self.chance_list, love.math.random(1, #self.chance_list))
        end
    }
end

function Director:new(stage)
    self.stage = stage
    self.timer = Timer()

    self:setupPointsTable()
    self:setupSpawnTable()

    self.difficulty = 1
    self.round_duration = 22
    self.cycle_duration = 5

    self.round_cooldown     = CooldownTimer(self.round_duration)
    self.resource_cooldown  = CooldownTimer(16)
    self.powerup_cooldown   = CooldownTimer(30)
    self.ammo_cooldown      = CooldownTimer(3)
    self.cycle_cooldown     = CooldownTimer(self.cycle_duration)
    self.cycle_time         = 0

    self:setEnemySpawnsForThisRound()
end

function Director:setupSpawnTable()
    self.resource_spawn_chances = chanceList({'Boost', 28}, {'HP', 14}, {'SkillPoint', 58})

    self.enemy_spawn_chances = {
        [1] = chanceList({'Rock', 1}),
        [2] = chanceList({'Rock', 8}, {'Shooter', 4}),
        [3] = chanceList({'Rock', 8}, {'Shooter', 8}),
        [4] = chanceList({'Rock', 4}, {'Shooter', 8}),
    }
    for i = 5, 1024 do
        self.enemy_spawn_chances[i] = chanceList(
            {'Rock', love.math.random(2, 12)},
            {'Shooter', love.math.random(2, 12)}
        )
    end
end

function Director:setupPointsTable()
    self.difficulty_to_points = {}
    self.difficulty_to_points[1] = 16
    for i = 2, 1024, 4 do
        self.difficulty_to_points[i] = self.difficulty_to_points[i-1] + 8
        self.difficulty_to_points[i+1] = self.difficulty_to_points[i]
        self.difficulty_to_points[i+2] = math.floor(self.difficulty_to_points[i+1]/1.5)
        self.difficulty_to_points[i+3] = math.floor(self.difficulty_to_points[i+2]*2)
    end

    self.enemy_to_points = {
        ['Rock'] = 1,
        ['Shooter'] = 2,
    }
end

function Director:setEnemySpawnsForThisRound()
    local points = self.difficulty_to_points[self.difficulty]
    print("D: LEVEL " .. self.difficulty .. " " .. points .. " pts")

    -- Find enemies
    local enemy_list = {}
    while points > 0 do
        local enemy = self.enemy_spawn_chances[self.difficulty]:next()
        points = points - self.enemy_to_points[enemy]
        table.insert(enemy_list, enemy)
    end

    -- Find enemies spawn times
    local enemy_spawn_times = {}
    for i = 1, #enemy_list do
        enemy_spawn_times[i] = utils.random(0, self.round_duration)
    end
    table.sort(enemy_spawn_times, function(a, b) return a < b end)

    -- Set spawn enemy timer
    for i = 1, #enemy_spawn_times do
        -- print("D:     " .. enemy_list[i] .. " @ " .. enemy_spawn_times[i])
        self.timer:after(enemy_spawn_times[i], function()
            print("D:   +" .. enemy_list[i])
            self.stage.area:addGameObject(enemy_list[i], utils.random(0, gw), utils.random(0, gh))
        end)
    end
end

function Director:update(dt)
    self.timer:update(dt)

    self.round_cooldown(dt, function()
        self.difficulty = self.difficulty + 1
        self:setEnemySpawnsForThisRound()
    end)

    self.cycle_time = self.cycle_cooldown(dt, function()
        self.stage.player:tick()
    end)

    self.resource_cooldown(dt, function()
        local resource = self.resource_spawn_chances:next()
        print("D:   +" .. resource)
        self.stage.area:addGameObject(resource, utils.random(0, gw), utils.random(0, gh))
    end)

    self.powerup_cooldown(dt, function()
        self.stage:addRandomAttackResource()
    end)

    self.ammo_cooldown(dt, function()
        self.stage.area:addGameObject('Ammo', utils.random(0, gw), utils.random(0, gh))
    end)
end