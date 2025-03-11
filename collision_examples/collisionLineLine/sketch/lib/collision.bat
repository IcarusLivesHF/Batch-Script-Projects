set "sqrt(N)=( M=(N),j=M/(11264)+40, j=(M/j+j)>>1, j=(M/j+j)>>1, j=(M/j+j)>>1, j=(M/j+j)>>1, j=(M/j+j)>>1, j+=(M-j*j)>>31 )"

:_collision
rem  PointPoint x1 y1 x2 y2                      <rtn> !COLLISION! 0:false or 1:true
set "PointPoint=COLLISION=(((~(x2-x1)>>31)&1)&((~(x1-x2)>>31)&1)) & (((~(y2-y1)>>31)&1)&((~(y1-y2)>>31)&1))"

rem  PointCircle x1 y1 cx cy r                   <rtn> !COLLISION! 0:false or 1:true
set "PointCircle=a=x1-cx,b=y1-cy,COLLISION=((~((r - !sqrt(n):n=a*a + b*b!)-1)>>31)&1)"

rem  CircleCircle c1x c1y c1r c2x c2y c2r        <rtn> !COLLISION! 0:false or 1:true
set "CircleCircle=a=c1x-c2x,b=c1y-c2y,COLLISION=((~((c1r+c2r)-!sqrt(n):n=a*a + b*b!)>>31)&1)"

rem  PointRect px py rx ry rw rh                 <rtn> !COLLISION! 0:false or 1:true
set "PointRect=COLLISION=((~(px-rx)>>31)&1) & ((~((rx+rw)-px+1)>>31)&1) & ((~(py-ry)>>31)&1) & ((~((ry+rh)-py+1)>>31)&1)"
	
REM  RectRect r1x r1y r1w r1h r2x r2y r2w r2h    <rtn> !COLLISION! 0:false or 1:true
set "RectRect=COLLISION=((~((r1x+r1w)-r2x+1)>>31)&1) & ((~((r2x+r2w)-r1w+1)>>31)&1) & ((~((r1y+r1h)-r2y+1)>>31)&1) & ((~((r2y+r2h)-r1y+1)>>31)&1)"

rem  CircleRect cx cy r rx ry rw rh              <rtn> !COLLISION! 0:false or 1:true
set "CircleRect=tx=cx, ty=cy,a=cx - rx,b=cy - ry,c=rx+rw,d=ry+rh,e=(((c) - cx) >> 31) & 1,f=(((d) - cy) >> 31) & 1,g=cx-((((a >> 31) & 1) * rx) + ((1 - ((a >> 31) & 1)) * (1 - e) * cx) + e * c),h=cy-((((b >> 31) & 1) * ry) + ((1 - ((b >> 31) & 1)) * (1 - f) * cy) + f * d),COLLISION=((~(r-!sqrt(n):n=g*g + h*h!)>>31)&1)"

REM  LinePoint x1 y1 x2 y2 px py                 <rtn> !COLLISION! 0:false or 1:true
set "LinePoint=a=x1-x2, b=y1-y2, c=px-x1, d=py-y1, e=px-x2, f=py-y2,COLLISION=((~((!sqrt(n):n=a*a + b*b!)-((!sqrt(n):n=c*c + d*d!)+(!sqrt(n):n=e*e + f*f!)))>>31)&1)"

rem  LineCircle x1 y1 x2 y2 cx cy r              <rtn> !COLLISION! 0:false or 1:true
set "LineCircle=a=x2-x1,b=y2-y1, len=!sqrt(n):n=a*a + b*b!, dot=(10 * ( (cx-x1)*a + (cy-y1)*b ) / (len * len)), clx=(x1 + dot * a / 10), cly=(y1 + dot * b / 10), d=clx-cx, e=cly-cy, COLLISION=((~(r-!sqrt(n):n=d*d + e*e!)>>31)&1)"

rem  LineLine x1 y1 x2 y2 x3 y3 x4 y4            <rtn> !COLLISION! 0:false or 1:true
set "LineLine=a=x4-x3,b=y4-y3,c=x1-x3,d=y1-y3,e=x2-x1,f=y2-y1,g=b*e-a*f,uA=10 * (a*d - b*c) / g, uB=10 * (e*d - f*c) / g, COLLISION=((~(uA-0)>>31)&1) & ((~(10-uA)>>31)&1) & ((~(uB-0)>>31)&1) & ((~(10-uB)>>31)&1)"

rem  LineRect x1 y1 rx ry rw rh                  <rtn> !COLLISION! 0:false or 1:true
set "LineRect=x1=x1,y1=y1,x2=x2,y2=y2, COLLISION=(x3=rx, y3=ry, x4=rx, y4=ry+rh, ^!lineLine^!) | (x3=rx+rw,y3=ry, x4=rx+rw,y4=ry+rh, ^!lineLine^!) | (x3=rx, y3=ry, x4=rx+rw,y4=ry, ^!lineLine^!) | (x3=rx,y3=ry+rh,x4=rx+rw,y4=ry+rh, ^!lineLine^!)"

rem  LineRect_EDGE x1 y1 rx ry rw rh             <rtn> !COLLISION! !top! !bottom! !left! !right! 0:false or 1:true
set "LineRect_EDGE=x1=x1,y1=y1,x2=x2,y2=y2, x3=rx, y3=ry, x4=rx, y4=ry+rh, ^!lineLine^!, left=COLLISION, x3=rx+rw,y3=ry, x4=rx+rw,y4=ry+rh, ^!lineLine^!, right=COLLISION, x3=rx, y3=ry, x4=rx+rw,y4=ry, ^!lineLine^!, top=COLLISION, x3=rx,y3=ry+rh,x4=rx+rw,y4=ry+rh, ^!lineLine^!, bottom=COLLISION, COLLISION=left | right | top | bottom"
