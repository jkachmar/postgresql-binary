module PostgreSQLBinary.Time where

import PostgreSQLBinary.Prelude hiding (second)
import Data.Time.Calendar.Julian


{-# INLINABLE dayToPostgresJulian #-}
dayToPostgresJulian :: Day -> Integer
dayToPostgresJulian =
  (+ (2400001 - 2451545)) . toModifiedJulianDay

{-# INLINABLE postgresJulianToDay #-}
postgresJulianToDay :: Int64 -> Day
postgresJulianToDay =
  ModifiedJulianDay . fromIntegral . subtract (2400001 - 2451545)

{-# INLINABLE microsToTimeOfDay #-}
microsToTimeOfDay :: Int64 -> TimeOfDay
microsToTimeOfDay =
  evalState $ do
    h <- state $ flip divMod $ 10 ^ 6 * 60 * 60
    m <- state $ flip divMod $ 10 ^ 6 * 60
    u <- get
    return $
      TimeOfDay (fromIntegral h) (fromIntegral m) (microsToPico u)

{-# INLINABLE microsToUTC #-}
microsToUTC :: Int64 -> UTCTime
microsToUTC =
  evalState $ do
    d <- state $ flip divMod $ 10^6 * 60 * 60 * 24
    u <- get
    return $
      UTCTime (postgresJulianToDay d) (microsToDiffTime u)

{-# INLINABLE microsToPico #-}
microsToPico :: Int64 -> Pico
microsToPico =
  unsafeCoerce . (* (10^6)) . (fromIntegral :: Int64 -> Integer)

{-# INLINABLE microsToDiffTime #-}
microsToDiffTime :: Int64 -> DiffTime
microsToDiffTime =
  unsafeCoerce microsToPico

{-# INLINABLE microsToLocalTime #-}
microsToLocalTime :: Int64 -> LocalTime
microsToLocalTime =
  evalState $ do
    d <- state $ flip divMod $ 10^6 * 60 * 60 * 24
    u <- get
    return $
      LocalTime (postgresJulianToDay d) (microsToTimeOfDay u)

{-# INLINABLE secsToTimeOfDay #-}
secsToTimeOfDay :: Double -> TimeOfDay
secsToTimeOfDay =
  evalState $ do
    h <- state $ flip divMod' $ 60 * 60
    m <- state $ flip divMod' $ 60
    s <- get
    return $
      TimeOfDay (fromIntegral h) (fromIntegral m) (secsToPico s)

{-# INLINABLE secsToUTC #-}
secsToUTC :: Double -> UTCTime
secsToUTC =
  evalState $ do
    d <- state $ flip divMod' $ 60 * 60 * 24
    s <- get
    return $
      UTCTime (postgresJulianToDay d) (secsToDiffTime s)

{-# INLINABLE secsToLocalTime #-}
secsToLocalTime :: Double -> LocalTime
secsToLocalTime =
  evalState $ do
    d <- state $ flip divMod' $ 60 * 60 * 24
    s <- get
    return $
      LocalTime (postgresJulianToDay d) (secsToTimeOfDay s)

{-# INLINABLE secsToPico #-}
secsToPico :: Double -> Pico
secsToPico s =
  unsafeCoerce (truncate $ toRational s * 10 ^ 12 :: Integer)

{-# INLINABLE secsToDiffTime #-}
secsToDiffTime :: Double -> DiffTime
secsToDiffTime =
  unsafeCoerce secsToPico

{-# INLINABLE localTimeToMicros #-}
localTimeToMicros :: LocalTime -> Int64
localTimeToMicros (LocalTime dayX timeX) =
  let d = dayToPostgresJulian dayX
      p = unsafeCoerce $ timeOfDayToTime timeX
      in 10^6 * 60 * 60 * 24 * fromIntegral d + fromIntegral (div p (10^6))

{-# INLINABLE localTimeToSecs #-}
localTimeToSecs :: LocalTime -> Double
localTimeToSecs (LocalTime dayX timeX) =
  let d = dayToPostgresJulian dayX
      p = unsafeCoerce $ timeOfDayToTime timeX
      in 60 * 60 * 24 * fromIntegral d + fromRational (p % (10^12))

{-# INLINABLE utcToMicros #-}
utcToMicros :: UTCTime -> Int64
utcToMicros (UTCTime dayX diffTimeX) =
  let d = dayToPostgresJulian dayX
      p = unsafeCoerce diffTimeX
      in 10^6 * 60 * 60 * 24 * fromIntegral d + fromIntegral (div p (10^6))

{-# INLINABLE utcToSecs #-}
utcToSecs :: UTCTime -> Double
utcToSecs (UTCTime dayX diffTimeX) =
  let d = dayToPostgresJulian dayX
      p = unsafeCoerce diffTimeX
      in 60 * 60 * 24 * fromIntegral d + fromRational (p % (10^12))


-- * Constants in microseconds according to Julian dates standard
-------------------------
-- According to
-- http://www.postgresql.org/docs/9.1/static/datatype-datetime.html
-- Postgres uses Julian dates internally
-------------------------

yearMicros   :: Int64 = truncate (365.2425 * fromIntegral dayMicros :: Rational)
dayMicros    :: Int64 = 24 * hourMicros
hourMicros   :: Int64 = 60 * minuteMicros
minuteMicros :: Int64 = 60 * secondMicros
secondMicros :: Int64 = 10 ^ 6 

