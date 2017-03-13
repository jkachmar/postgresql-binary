-- |
-- Models of supported data structures according to the serialisation format.
module PostgreSQL.Binary.Data where

import PostgreSQL.Binary.Prelude
import qualified Network.IP.Addr as IPAddr

-- | 
-- A representation of a data serializable to the PostgreSQL array binary format.
-- 
-- Consists of a vector of dimensions, a vector of encoded elements,
-- a flag specifying, whether it contains any nulls, and an oid.
type Array =
  (Vector ArrayDimension, Vector Content, Bool, OID)

-- | 
-- A width and a lower bound.
-- 
-- Currently the lower bound is only allowed to have a value of @1@.
type ArrayDimension =
  (Word32, Word32)

-- |
-- An encoded value. 'Nothing' if it represents a @NULL@.
type Content =
  Maybe ByteString

-- |
-- A Postgres OID of a type.
type OID =
  Word32

-- |
-- A representation of a composite Postgres data (Record or Row).
type Composite =
  Vector (OID, Content)

-- |
-- HStore.
type HStore =
  Vector (ByteString, Content)

-- |
-- The four components of UUID.
type UUID =
  (Word32, Word32, Word32, Word32)

-- |
-- Representation of the PostgreSQL Numeric encoding.
-- 
-- Consists of the following components:
-- 
-- * Point index
-- * Sign code
-- * Components
-- 
type Numeric =
  (Int16, Word16, Vector Int16)


-- |
-- Representation of the PostgreSQL Network Address Type @inet@.
--
-- The Inet type holds an IPv4 or IPv6 host address, and its subnet.
type Inet = IPAddr.NetAddr IPAddr.IP

-- | Address family AF_INET
afInet :: Word8
afInet = 2

-- | Address family AF_INET6
afInet6 :: Word8
afInet6 = 3