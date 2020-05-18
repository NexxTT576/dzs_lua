local GameAudio = {}

function GameAudio.init()
    GameAudio.saved = cc.UserDefault:getInstance():getBoolForKey(GAME_SETTING.HAS_SAVE)
    if GameAudio.saved == false then
        cc.UserDefault:getInstance():setBoolForKey(GAME_SETTING.HAS_SAVE, true)
        cc.UserDefault:getInstance():setBoolForKey(GAME_SETTING.ENABLE_SFX, true)
        cc.UserDefault:getInstance():setBoolForKey(GAME_SETTING.ENABLE_MUSIC, true)
        cc.UserDefault:getInstance():flush()
    end

    GameAudio.soundOn = cc.UserDefault:getInstance():getBoolForKey(GAME_SETTING.ENABLE_MUSIC)
    --@TODO 2020-05-18 10:42:52 背景音乐关闭
    GameAudio.soundOn = false
    GameAudio.sfxOn = cc.UserDefault:getInstance():getBoolForKey(GAME_SETTING.ENABLE_SFX)
    GameAudio.curMusicName = ""
    GameAudio.curMusicIsLoop = false
end

function GameAudio.setSoundEnable(enable)
    cc.UserDefault:getInstance():setBoolForKey(GAME_SETTING.ENABLE_MUSIC, enable)
    cc.UserDefault:getInstance():flush()
    GameAudio.soundOn = cc.UserDefault:getInstance():getBoolForKey(GAME_SETTING.ENABLE_MUSIC)
end

function GameAudio.setSfxEnable(enable)
    cc.UserDefault:getInstance():setBoolForKey(GAME_SETTING.ENABLE_SFX, enable)
    cc.UserDefault:getInstance():flush()
    GameAudio.sfxOn = cc.UserDefault:getInstance():getBoolForKey(GAME_SETTING.ENABLE_SFX)
end

function GameAudio.preloadMusic(filename)
    audio.preloadMusic(filename)
end

local HIT_SOUND = true --not GAME_DEBUG

function GameAudio.playMusic(filename, isLoop)
    dump(filename)
    if GameAudio.soundOn == true and HIT_SOUND then
        if GameAudio.curMusicName ~= filename or GameAudio.curMusicIsLoop ~= isLoop then
            GameAudio.curMusicName = filename
            GameAudio.curMusicIsLoop = isLoop

            audio.stopMusic(true)
            local loop = isLoop or false
            audio.playMusic(filename, loop)
        end
    end
end

function GameAudio.stopMusic(isReleaseData)
    if (audio.isMusicPlaying()) and HIT_SOUND then
        GameAudio.curMusicName = ""
        audio.stopMusic(isReleaseData)
    end
end

function GameAudio.playSound(filename, isLoop)
    if (GameAudio.sfxOn == true) and HIT_SOUND then
        local loop = isLoop or false
        audio.playSound(filename, loop)
    end
end

-- 播放背景音乐
function GameAudio.playMainmenuMusic(isLoop)
    local curTime = tonumber(os.date("%H", os.time()))
    local soundName = GAME_SOUND.title_day
    -- 夜晚背景显示
    if (curTime > 18 or curTime < 6) then
        soundName = GAME_SOUND.title_night
    end

    GameAudio.playMusic(soundName, isLoop)
end

return GameAudio
