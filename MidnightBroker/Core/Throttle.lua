local _, MB = ...

MB.Throttle = {
    buckets = {},
}
MB:RegisterModule("Throttle", MB.Throttle)

function MB.Throttle:Initialize()
    self.frame = CreateFrame("Frame")
    self.frame:SetScript("OnUpdate", function(_, elapsed)
        self:OnUpdate(elapsed)
    end)
end

function MB.Throttle:Register(bucketId, interval, callback)
    self.buckets[bucketId] = {
        interval = interval,
        elapsed = 0,
        callback = callback,
    }
end

function MB.Throttle:Unregister(bucketId)
    self.buckets[bucketId] = nil
end

function MB.Throttle:RunNow(bucketId)
    local bucket = self.buckets[bucketId]
    if bucket and bucket.callback then
        bucket.callback()
    end
end

function MB.Throttle:OnUpdate(elapsed)
    for _, bucket in pairs(self.buckets) do
        bucket.elapsed = bucket.elapsed + elapsed
        if bucket.elapsed >= bucket.interval then
            bucket.elapsed = 0
            bucket.callback()
        end
    end
end
