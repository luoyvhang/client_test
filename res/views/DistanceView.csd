<GameFile>
  <PropertyGroup Name="DistanceView" Type="Node" ID="c2e4cefd-9e80-4a1d-ba38-87e0338b79cf" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000" />
      <ObjectData Name="Node" Tag="13" ctype="GameNodeObjectData">
        <Size X="0.0000" Y="0.0000" />
        <Children>
          <AbstractNodeData Name="black" ActionTag="654621941" Tag="895" IconVisible="False" RightMargin="-200.0000" TopMargin="-200.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="178" ComboBoxIndex="1" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
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
          <AbstractNodeData Name="MainPanel" ActionTag="1106187585" Tag="14" IconVisible="False" LeftMargin="-400.0000" RightMargin="-400.0000" TopMargin="-250.0000" BottomMargin="-250.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="800.0000" Y="500.0000" />
            <Children>
              <AbstractNodeData Name="bg" ActionTag="-1124869526" Tag="15" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" PercentWidthEnable="True" PercentHeightEnable="True" PercentWidthEnabled="True" PercentHeightEnabled="True" Scale9Enable="True" LeftEage="167" RightEage="167" TopEage="118" BottomEage="118" Scale9OriginX="167" Scale9OriginY="118" Scale9Width="173" Scale9Height="124" ctype="ImageViewObjectData">
                <Size X="800.0000" Y="500.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="400.0000" Y="250.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.5000" />
                <PreSize X="1.0000" Y="1.0000" />
                <FileData Type="Normal" Path="views/setting/board.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="title" ActionTag="-1801542316" Tag="16" IconVisible="False" PositionPercentXEnabled="True" LeftMargin="335.0000" RightMargin="335.0000" TopMargin="11.5000" BottomMargin="451.5000" FontSize="32" LabelText="作弊提示" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="130.0000" Y="37.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="400.0000" Y="470.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.9400" />
                <PreSize X="0.1625" Y="0.0740" />
                <FontResource Type="Normal" Path="views/font/fangzheng.ttf" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="close" ActionTag="-1185861831" CallBackType="Click" CallBackName="clickBack" Tag="230" IconVisible="False" LeftMargin="761.0000" RightMargin="-35.0000" TopMargin="-36.0000" BottomMargin="462.0000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="44" Scale9Height="52" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="74.0000" Y="74.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="798.0000" Y="499.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.9975" Y="0.9980" />
                <PreSize X="0.0925" Y="0.1480" />
                <TextColor A="255" R="65" G="65" B="70" />
                <NormalFileData Type="Normal" Path="views/enterroom/close.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="list" ActionTag="-1148600569" Tag="223" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="30.0000" RightMargin="30.0000" TopMargin="75.0000" BottomMargin="25.0000" TouchEnable="True" ClipAble="True" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" IsBounceEnabled="True" ScrollDirectionType="0" ItemMargin="5" DirectionType="Vertical" ctype="ListViewObjectData">
                <Size X="740.0000" Y="400.0000" />
                <Children>
                  <AbstractNodeData Name="item" ActionTag="-1562964925" Tag="221" IconVisible="False" BottomMargin="340.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                    <Size X="740.0000" Y="60.0000" />
                    <Children>
                      <AbstractNodeData Name="frame" ActionTag="-1712049950" Tag="229" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" TopMargin="-2.5000" BottomMargin="-2.5000" Scale9Enable="True" LeftEage="144" RightEage="144" TopEage="13" BottomEage="13" Scale9OriginX="144" Scale9OriginY="13" Scale9Width="149" Scale9Height="15" ctype="ImageViewObjectData">
                        <Size X="740.0000" Y="65.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="370.0000" Y="30.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.5000" Y="0.5000" />
                        <PreSize X="1.0000" Y="1.0833" />
                        <FileData Type="Normal" Path="views/lobby/bar1.png" Plist="" />
                      </AbstractNodeData>
                      <AbstractNodeData Name="left" ActionTag="-75602423" Tag="224" IconVisible="False" PositionPercentYEnabled="True" LeftMargin="13.0000" RightMargin="681.0000" TopMargin="7.0000" BottomMargin="7.0000" LeftEage="15" RightEage="15" TopEage="15" BottomEage="15" Scale9OriginX="15" Scale9OriginY="15" Scale9Width="172" Scale9Height="172" ctype="ImageViewObjectData">
                        <Size X="46.0000" Y="46.0000" />
                        <Children>
                          <AbstractNodeData Name="name" ActionTag="1772345283" Tag="225" IconVisible="False" PositionPercentYEnabled="True" LeftMargin="55.0000" RightMargin="-60.0000" TopMargin="9.0000" BottomMargin="9.0000" FontSize="24" LabelText="张三" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                            <Size X="51.0000" Y="28.0000" />
                            <AnchorPoint ScaleY="0.5000" />
                            <Position X="55.0000" Y="23.0000" />
                            <Scale ScaleX="1.0000" ScaleY="1.0000" />
                            <CColor A="255" R="255" G="255" B="255" />
                            <PrePosition X="1.1957" Y="0.5000" />
                            <PreSize X="1.1087" Y="0.6087" />
                            <FontResource Type="Normal" Path="views/font/fangzheng.ttf" Plist="" />
                            <OutlineColor A="255" R="255" G="0" B="0" />
                            <ShadowColor A="255" R="110" G="110" B="110" />
                          </AbstractNodeData>
                        </Children>
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="36.0000" Y="30.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.0486" Y="0.5000" />
                        <PreSize X="0.0622" Y="0.7667" />
                        <FileData Type="Normal" Path="views/lobby/defaultHead.png" Plist="" />
                      </AbstractNodeData>
                      <AbstractNodeData Name="distance" ActionTag="748596835" Tag="228" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="288.0000" RightMargin="362.0000" TopMargin="17.5000" BottomMargin="17.5000" FontSize="22" LabelText="距离未知" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                        <Size X="90.0000" Y="25.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="333.0000" Y="30.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.4500" Y="0.5000" />
                        <PreSize X="0.1216" Y="0.4167" />
                        <FontResource Type="Normal" Path="views/font/fangzheng.ttf" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                      <AbstractNodeData Name="right" ActionTag="99342716" Tag="226" IconVisible="False" PositionPercentYEnabled="True" LeftMargin="512.0000" RightMargin="182.0000" TopMargin="7.0000" BottomMargin="7.0000" LeftEage="66" RightEage="66" TopEage="66" BottomEage="66" Scale9OriginX="66" Scale9OriginY="66" Scale9Width="70" Scale9Height="70" ctype="ImageViewObjectData">
                        <Size X="46.0000" Y="46.0000" />
                        <Children>
                          <AbstractNodeData Name="name" ActionTag="-958054067" Tag="227" IconVisible="False" PositionPercentYEnabled="True" LeftMargin="55.0000" RightMargin="-59.0000" TopMargin="9.0000" BottomMargin="9.0000" FontSize="24" LabelText="李四" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                            <Size X="50.0000" Y="28.0000" />
                            <AnchorPoint ScaleY="0.5000" />
                            <Position X="55.0000" Y="23.0000" />
                            <Scale ScaleX="1.0000" ScaleY="1.0000" />
                            <CColor A="255" R="255" G="255" B="255" />
                            <PrePosition X="1.1957" Y="0.5000" />
                            <PreSize X="1.0870" Y="0.6087" />
                            <FontResource Type="Normal" Path="views/font/fangzheng.ttf" Plist="" />
                            <OutlineColor A="255" R="255" G="0" B="0" />
                            <ShadowColor A="255" R="110" G="110" B="110" />
                          </AbstractNodeData>
                        </Children>
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="535.0000" Y="30.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition X="0.7230" Y="0.5000" />
                        <PreSize X="0.0622" Y="0.7667" />
                        <FileData Type="Normal" Path="views/lobby/defaultHead.png" Plist="" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint />
                    <Position Y="340.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition Y="0.8500" />
                    <PreSize X="1.0000" Y="0.1500" />
                    <SingleColor A="255" R="150" G="200" B="255" />
                    <FirstColor A="255" R="150" G="200" B="255" />
                    <EndColor A="255" R="255" G="255" B="255" />
                    <ColorVector ScaleY="1.0000" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="400.0000" Y="225.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.4500" />
                <PreSize X="0.9250" Y="0.8000" />
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