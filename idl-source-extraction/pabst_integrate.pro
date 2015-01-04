function pabst_integrate,klim,bprof,minth,maxth,minep,maxep,thint,epint,dI

print,'Generating initial integrals...'
pxs=1.0
spxs=pxs/dI
vals=fltarr((2*klim)+1,(2*klim)+1,((maxep-minep)/epint)+1,((maxth-minth)/thint)+1)

thc=0
epc=0
    for ep=minep,maxep,epint do begin
        thc=0
    for th=minth,maxth,thint do begin


for i=-klim,klim do begin
for j=-klim,klim do begin
if (i eq 0) and (j eq 0) then begin
vals[i+klim,j+klim,epc,thc]=1.0
endif else begin
ccnt=0
subvals=fltarr((2*dI)+1,(2*dI)+1)
  for m=-dI,dI do begin
  for n=-dI,dI do begin
      l1=sqrt((i+(m*spxs))^2.0+(j+(n*spxs))^2.0)
      thp=atan((j+(n*spxs))/(i+(m*spxs)))
      phi=th-thp
      dist=sqrt(ep^2.0 + l1^2.0 - (2*ep*l1*cos(phi)))
      subvals[ccnt]=interpolate(bprof,[dist])
      ccnt=ccnt+1
  endfor
  endfor
  ;print,i,j,int
  vals[i+klim,j+klim,epc,thc]=mean(subvals)
endelse
endfor
endfor

  thc=thc+1
endfor
  epc=epc+1
endfor

print,maxth,minth,maxep,minep,epint,thint

return,vals

end
