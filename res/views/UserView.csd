<GameFile>
  <PropertyGroup Name="UserView" Type="Node" ID="fb15a6c2-dad0-411b-88c5-27dee95e2a14" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000" />
      <ObjectData Name="Node" Tag="58" ctype="GameNodeObjectData">
        <Size X="0.0000" Y="0.0000" />
        <Children>
          <AbstractNodeData Name="black" ActionTag="1707756025" Tag="272" IconVisible="False" RightMargin="-200.0000" TopMargin="-200.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="178" ComboBoxIndex="1" ColorAngle="90.0000" ctype="PanelObjectData">
            <Size X="200.0000" Y="200.0000" />
            <AnchorPoint />
            <Position />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <SingleColor A="255" R="0" G="0" B="0" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="MainPanel" ActionTag="689607618" Tag="59" IconVisible="False" LeftMargin="-300.0000" RightMargin="-300.0000" TopMargin="-200.0000" BottomMargin="-200.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="600.0000" Y="400.0000" />
            <Children>
              <AbstractNodeData Name="frame" ActionTag="-897822171" Tag="261" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" PercentWidthEnable="True" PercentHeightEnable="True" PercentWidthEnabled="True" PercentHeightEnabled="True" Scale9Enable="True" LeftEage="144" RightEage="144" TopEage="13" BottomEage="13" Scale9OriginX="144" Scale9OriginY="13" Scale9Width="149" Scale9Height="15" ctype="ImageViewObjectData">
                <Size X="600.0000" Y="400.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="300.0000" Y="200.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.5000" />
                <PreSize X="1.0000" Y="1.0000" />
                <FileData Type="Normal" Path="views/lobby/bar1.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="title" ActionTag="-709390991" Tag="262" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="258.0000" RightMargin="258.0000" TopMargin="26.4994" BottomMargin="348.5006" FontSize="20" LabelText="个人信息" OutlineEnabled="True" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="84.0000" Y="25.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="300.0000" Y="361.0006" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.9025" />
                <PreSize X="0.1400" Y="0.0625" />
                <FontResource Type="Normal" Path="views/font/fangzheng.ttf" Plist="" />
                <OutlineColor A="255" R="0" G="128" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="close" ActionTag="878827294" CallBackType="Click" CallBackName="clickBack" Tag="273" IconVisible="False" LeftMargin="561.7858" RightMargin="-35.7858" TopMargin="-35.0315" BottomMargin="361.0315" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="44" Scale9Height="52" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="74.0000" Y="74.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="598.7858" Y="398.0315" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.9980" Y="0.9951" />
                <PreSize X="0.1233" Y="0.1850" />
                <TextColor A="255" R="65" G="65" B="70" />
                <NormalFileData Type="Normal" Path="views/enterroom/close.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="list" ActionTag="1757895655" Tag="263" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="50.0000" RightMargin="50.0000" TopMargin="125.0000" BottomMargin="125.0000" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" ScrollDirectionType="0" ItemMargin="20" DirectionType="Vertical" ctype="ListViewObjectData">
                <Size X="500.0000" Y="150.0000" />
                <Children>
                  <AbstractNodeData Name="name" ActionTag="1707297848" Tag="274" IconVisible="False" BottomMargin="160.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                    <Size X="500.0000" Y="60.0000" />
                    <Children>
                      <AbstractNodeData Name="bg" ActionTag="1436215181" Tag="275" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" PercentWidthEnable="True" PercentHeightEnable="True" PercentWidthEnabled="True" PercentHeightEnabled="True" Scale9Enable="True" LeftEage="54" RightEage="54" TopEage="14" BottomEage="14" Scale9OriginX="54" Scale9OriginY="14" Scale9Width="58" Scale9Height="17" ctype="ImageViewObjectData">
                        <Size X="500.0000" Y="60.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="250.0000" Y="30.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.5000" Y="0.5000" />
                        <PreSize X="1.0000" Y="1.0000" />
                        <FileData Type="Normal" Path="views/createroom/bar3.png" Plist="" />
                      </AbstractNodeData>
                      <AbstractNodeData Name="title" ActionTag="1118135470" Tag="276" IconVisible="False" PositionPercentYEnabled="True" LeftMargin="59.5000" RightMargin="379.5000" TopMargin="15.0000" BottomMargin="15.0000" FontSize="26" LabelText="昵称:" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="61.0000" Y="30.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="90.0000" Y="30.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.1800" Y="0.5000" />
                        <PreSize X="0.1220" Y="0.5000" />
                        <FontResource Type="Normal" Path="views/font/fangzheng.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                      <AbstractNodeData Name="value" ActionTag="594172192" Tag="277" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="250.0000" RightMargin="250.0000" TopMargin="30.0000" BottomMargin="30.0000" FontSize="32" LabelText="" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="0.0000" Y="0.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="250.0000" Y="30.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.5000" Y="0.5000" />
                        <PreSize X="0.0000" Y="0.0000" />
                        <FontResource Type="Normal" Path="views/font/fangzheng.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint />
                    <Position Y="160.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition Y="0.7273" />
                    <PreSize X="1.0000" Y="0.2727" />
                    <SingleColor A="255" R="150" G="200" B="255" />
                    <FirstColor A="255" R="150" G="200" B="255" />
                    <EndColor A="255" R="255" G="255" B="255" />
                    <ColorVector ScaleY="1.0000" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="id" ActionTag="103668736" ZOrder="1" Tag="264" IconVisible="False" BottomMargin="90.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" ctype="PanelObjectData">
                    <Size X="500.0000" Y="60.0000" />
                    <Children>
                      <AbstractNodeData Name="bg" ActionTag="525823941" Tag="270" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" PercentWidthEnable="True" PercentHeightEnable="True" PercentWidthEnabled="True" PercentHeightEnabled="True" Scale9Enable="True" LeftEage="54" RightEage="54" TopEage="14" BottomEage="14" Scale9OriginX="54" Scale9OriginY="14" Scale9Width="58" Scale9Height="17" ctype="ImageViewObjectData">
                        <Size X="500.0000" Y="60.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="250.0000" Y="30.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.5000" Y="0.5000" />
                        <PreSize X="1.0000" Y="1.0000" />
                        <FileData Type="Normal" Path="views/createroom/bar3.png" Plist="" />
                      </AbstractNodeData>
                      <AbstractNodeData Name="title" ActionTag="1702673502" Tag="265" IconVisible="False" PositionPercentYEnabled="True" LeftMargin="74.0000" RightMargin="394.0000" TopMargin="15.0000" BottomMargin="15.0000" FontSize="26" LabelText="ID:" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="32.0000" Y="30.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="90.0000" Y="30.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.1800" Y="0.5000" />
                        <PreSize X="0.0640" Y="0.5000" />
                        <FontResource Type="Normal" Path="views/font/fangzheng.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                      <AbstractNodeData Name="value" ActionTag="-1219146863" Tag="266" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="185.5000" RightMargin="185.5000" TopMargin="11.5000" BottomMargin="11.5000" FontSize="32" LabelText="0000000" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="129.0000" Y="37.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="250.0000" Y="30.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.5000" Y="0.5000" />
                        <PreSize X="0.2580" Y="0.6167" />
                        <FontResource Type="Normal" Path="views/font/fangzheng.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint />
                    <Position Y="80.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition Y="0.6000" />
                    <PreSize X="1.0000" Y="0.4000" />
                    <SingleColor A="255" R="150" G="200" B="255" />
                    <FirstColor A="255" R="150" G="200" B="255" />
                    <EndColor A="255" R="255" G="255" B="255" />
                    <ColorVector ScaleY="1.0000" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="vip" ActionTag="-2059090962" ZOrder="2" Tag="267" IconVisible="False" TopMargin="80.0000" BottomMargin="10.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                    <Size X="500.0000" Y="60.0000" />
                    <Children>
                      <AbstractNodeData Name="bg" ActionTag="-1973552147" Tag="271" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" PercentWidthEnable="True" PercentHeightEnable="True" PercentWidthEnabled="True" PercentHeightEnabled="True" Scale9Enable="True" LeftEage="54" RightEage="54" TopEage="14" BottomEage="14" Scale9OriginX="54" Scale9OriginY="14" Scale9Width="58" Scale9Height="17" ctype="ImageViewObjectData">
                        <Size X="500.0000" Y="60.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="250.0000" Y="30.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.5000" Y="0.5000" />
                        <PreSize X="1.0000" Y="1.0000" />
                        <FileData Type="Normal" Path="views/createroom/bar3.png" Plist="" />
                      </AbstractNodeData>
                      <AbstractNodeData Name="title" ActionTag="-1577479923" Tag="268" IconVisible="False" PositionPercentYEnabled="True" LeftMargin="68.0000" RightMargin="388.0000" TopMargin="15.0000" BottomMargin="15.0000" FontSize="26" LabelText="VIP:" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="44.0000" Y="30.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="90.0000" Y="30.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.1800" Y="0.5000" />
                        <PreSize X="0.0880" Y="0.5000" />
                        <FontResource Type="Normal" Path="views/font/fangzheng.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                      <AbstractNodeData Name="value" ActionTag="1416655882" Tag="269" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="239.5000" RightMargin="239.5000" TopMargin="11.5000" BottomMargin="11.5000" FontSize="32" LabelText="0" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="21.0000" Y="37.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="250.0000" Y="30.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.5000" Y="0.5000" />
                        <PreSize X="0.0420" Y="0.6167" />
                        <FontResource Type="Normal" Path="views/font/fangzheng.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint />
                    <Position />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition Y="0.0667" />
                    <PreSize X="1.0000" Y="0.4000" />
                    <SingleColor A="255" R="150" G="200" B="255" />
                    <FirstColor A="255" R="150" G="200" B="255" />
                    <EndColor A="255" R="255" G="255" B="255" />
                    <ColorVector ScaleY="1.0000" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="300.0000" Y="200.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.5000" />
                <PreSize X="0.8333" Y="0.3750" />
                <SingleColor A="255" R="150" G="150" B="255" />
                <FirstColor A="255" R="150" G="150" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>