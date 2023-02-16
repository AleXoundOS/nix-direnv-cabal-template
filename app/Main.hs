{-# LANGUAGE OverloadedStrings #-}

import Network.HTTP.Simple
import Text.XML.Cursor
import Text.XML
import qualified Data.ByteString.Lazy as BSL
import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Base64 as Base64 (encode)
import qualified Data.Text as T

-- ONVIF request to get motion detection configuration
onvifReq :: Request
onvifReq = setRequestMethod "POST"
         $ setRequestPath "/onvif/device_service"
         $ setRequestHost "localhost"
         $ setRequestPort 8080
         $ setRequestBodyLBS requestXml
         $ setRequestSecure False
         $ setRequestHeader "Content-Type" ["application/soap+xml"]
         $ setRequestHeader "Content-Length" [BS.pack $ show $ BSL.length requestXml]
         $ setRequestHeader "Authorization" [authHeader]
         $ defaultRequest
  where
    -- ONVIF request XML
    requestXml :: BSL.ByteString
    requestXml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
              <> "<env:Envelope xmlns:env=\"http://www.w3.org/2003/05/soap-envelope\""
              <> " xmlns:tds=\"http://www.onvif.org/ver10/deviceIO/wsdl\">"
              <> "<env:Body>"
              <> "<tds:GetVideoAnalyticsConfiguration>"
              <> "<tds:ConfigurationToken>VIDEO_ANALYTICS_1</tds:ConfigurationToken>"
              <> "</tds:GetVideoAnalyticsConfiguration>"
              <> "</env:Body>"
    -- Username and password
    username = "admin"
    password = "password"
    -- Base64 encoding of username and password
    authStr = username ++ ":" ++ password
    authBytes = BS.pack authStr
    authHeader = "Basic " <> Base64.encode authBytes
                 <> "</env:Envelope>"

main :: IO ()
main = do
  putStrLn "main has started"
  -- Make ONVIF request
  response <- httpLBS onvifReq

  -- Parse response
  let doc = parseLBS_ def $ getResponseBody response
      cursor = fromDocument doc
      motionDetect = cursor $/ element "GetVideoAnalyticsConfigurationResponse"
                           &/ element "Configuration"
                           &/ element "RuleEngineConfiguration"
                           &/ element "MotionDetection"
                           &/ element "Enabled"
                           &/ content

  -- Print motion detection configuration
  putStrLn $ "Motion detection configuration: " ++ T.unpack (head motionDetect)
