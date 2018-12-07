<GameFile>
  <PropertyGroup Name="win" Type="Node" ID="63c5bb63-7a1c-4d8f-9bc3-0f3f444b395e" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="30" Speed="0.7500">
        <Timeline ActionTag="1683506183" Property="FileData">
          <TextureFrame FrameIndex="0" Tween="False">
            <TextureFile Type="Normal" Path="views/animation/win/1.png" Plist="" />
          </TextureFrame>
          <TextureFrame FrameIndex="5" Tween="False">
            <TextureFile Type="Normal" Path="views/animation/win/2.png" Plist="" />
          </TextureFrame>
          <TextureFrame FrameIndex="10" Tween="False">
            <TextureFile Type="Normal" Path="views/animation/win/3.png" Plist="" />
          </TextureFrame>
          <TextureFrame FrameIndex="15" Tween="False">
            <TextureFile Type="Normal" Path="views/animation/win/4.png" Plist="" />
          </TextureFrame>
          <TextureFrame FrameIndex="20" Tween="False">
            <TextureFile Type="Normal" Path="views/animation/win/5.png" Plist="" />
          </TextureFrame>
          <TextureFrame FrameIndex="25" Tween="False">
            <TextureFile Type="Normal" Path="views/animation/win/6.png" Plist="" />
          </TextureFrame>
          <TextureFrame FrameIndex="30" Tween="False">
            <TextureFile Type="Normal" Path="views/animation/win/1.png" Plist="" />
          </TextureFrame>
        </Timeline>
        <Timeline ActionTag="1683506183" Property="FrameEvent">
          <EventFrame FrameIndex="30" Tween="False" Value="end" />
        </Timeline>
      </Animation>
      <ObjectData Name="Node" Tag="485" ctype="GameNodeObjectData">
        <Size X="0.0000" Y="0.0000" />
        <Children>
          <AbstractNodeData Name="tomato" ActionTag="1683506183" Tag="43" FrameEvent="end" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="-28.5000" RightMargin="-28.5000" TopMargin="-31.0000" BottomMargin="-31.0000" ctype="SpriteObjectData">
            <Size X="57.0000" Y="63.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position />
            <Scale ScaleX="1.5000" ScaleY="1.5000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <FileData Type="Normal" Path="views/animation/win/1.png" Plist="" />
            <BlendFunc Src="1" Dst="771" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>