module IPVM.Formats where

-- Human spec --

data Career = Career
  { version :: SemVer
  , requestor :: DID
  , nonce :: Word64
  , config :: Config -- FIXME
  , label :: Text
  , start :: NowOrLater
  , globalConfig :: GlobalConfig
  , verification :: VerificationConfig
  , jobs :: Map Text Job
  }

data GlobalConfig = GlobalConfig
  { wasmConfig :: WasmConfig
  , effectConfig :: EffectConfig
  , publishResults :: Bool
  , auth :: [UCAN] -- FIXME move to post-negotaited?
  }

data Ref
  = Absolute CID
  | Relative { label :: Text, index :: Word8 }

data Job = Job
  { call      :: Call
  , jobConfig :: JobConfig
  }

data JobConfig

data Call
  = Effect { object :: Text, action :: Text, timeoutSecs :: Maybe Word64 }
  | Wasm { wasm :: WasmBlob, input :: Map Text Ref, gas :: Word64, verification :: Verification }


-- Runner spec --
