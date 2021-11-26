---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Event handler that is called when the role of a player changes.
-- This will be triggered when a player claims or drops admin.
--
-- @tparam int _cn The client number of the player whose role changed
-- @tparam int _newRole The new role of the player
--
function PlayerList:onPlayerRoleChange(_cn, _newRole)

  local player = self.players[_cn]

  if (_newRole == CR_ADMIN) then
    player:setLevel(1)
  elseif (_newRole == CR_DEFAULT) then
    player:setLevel(0)
  end

end
