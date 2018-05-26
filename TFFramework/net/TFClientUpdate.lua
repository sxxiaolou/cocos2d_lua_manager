TFClientUpdateClass = TFClientUpdate
TFClientUpdate = TFClientUpdate:GetClientUpdate()

if not TFClientUpdate.initConfig then 
    function TFClientUpdate:initConfig()
        if TFClientResourceUpdate then
            local newUpdateFun =  TFClientResourceUpdate:GetClientResourceUpdate()

            newUpdateFun:SetUpdateLastBinFile("/../Library/lastfile.bin")
            newUpdateFun:SetUpdateLastestFile("check.xml")
            newUpdateFun:SetUpdateDefaultVersion("9.9.9")
            return
        end
        
        TFClientUpdate:SetUpdateLastBinFile("/../Library/lastfile.bin")
        TFClientUpdate:SetUpdateLastestFile("version.xml")
        TFClientUpdate:SetUpdateEditionPath("edition/")
        TFClientUpdate:SetUpateVersionFileType(".xml")
        TFClientUpdate:SetUpdateDefaultVersion("9.9.9")

    end
end

TFClientUpdate:initConfig()
return  TFClientUpdate