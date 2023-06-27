local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local riderQuery = sparrow.newQuery(database, {
    arguments = { "externalBody" },
    inclusions = { "externalBody", "rider" },
  })

  local motorcycleQuery = sparrow.newQuery(database, {
    arguments = { "externalBody" },
    inclusions = { "externalBody", "motorcycle" },
  })

  return function(dt)
    riderQuery:forEach(function(riderBody)
      motorcycleQuery:forEach(function(motorcycleBody)
        local localAnchorX = 0
        local localAnchorY = 0

        local localTargetX = 0
        local localTargetY = -0.8

        local anchorX, anchorY =
          riderBody:getWorldPoint(localAnchorX, localAnchorY)
        local targetX, targetY =
          motorcycleBody:getWorldPoint(localTargetX, localTargetY)

        local anchorLinearVelocityX, anchorLinearVelocityY =
          riderBody:getLinearVelocityFromWorldPoint(anchorX, anchorY)
        local targetLinearVelocityX, targetLinearVelocityY =
          motorcycleBody:getLinearVelocityFromWorldPoint(targetX, targetY)

        local errorX = targetX - anchorX
        local errorY = targetY - anchorY

        local linearVelocityErrorX = targetLinearVelocityX
          - anchorLinearVelocityX
        local linearVelocityErrorY = targetLinearVelocityY
          - anchorLinearVelocityY

        local springConstant = 50
        local damping = 5
        local maxForce = 50

        local forceX = errorX * springConstant + linearVelocityErrorX * damping
        local forceY = errorY * springConstant + linearVelocityErrorY * damping

        if forceX * forceX + forceY * forceY > maxForce * maxForce then
          local forceScale = maxForce
            / math.sqrt(forceX * forceX + forceY * forceY)

          forceX = forceX * forceScale
          forceY = forceY * forceScale
        end

        local localTargetAngle = 0.125 * math.pi

        local anchorAngle = riderBody:getAngle()
        local targetAngle = localTargetAngle + motorcycleBody:getAngle()

        local anchorAngularVelocity = riderBody:getAngularVelocity()
        local targetAngularVelocity = motorcycleBody:getAngularVelocity()

        local angleError = targetAngle - anchorAngle
        angleError = (angleError + math.pi) % 2 * math.pi - math.pi

        local angularVelocityError = targetAngularVelocity
          - anchorAngularVelocity

        local angularSpringConstant = 10
        local angularDamping = 1
        local maxTorque = 10

        local torque = angleError * angularSpringConstant
          + angularVelocityError * angularDamping

        if torque < -maxTorque then
          torque = -maxTorque
        elseif torque > maxTorque then
          torque = maxTorque
        end

        riderBody:applyForce(forceX, forceY, anchorX, anchorY)
        motorcycleBody:applyForce(-forceX, -forceY, anchorX, anchorY)

        riderBody:applyTorque(torque)
        motorcycleBody:applyTorque(-torque)
      end)
    end)
  end
end

return M
