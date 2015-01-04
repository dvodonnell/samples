function pabst_centroid,t,sx,sy,minth,maxth,minep,maxep,thint,epint

print,'Generating centroids...'
centroids=fltarr(n_elements(sx),2)
k=1

for n=0,n_elements(sx)-1 do begin
ttt=t[(sx[n]-k):(sx[n]+k),(sy[n]-k):(sy[n]+k)]

k=1

    ;check symmetry
    pxs=1.0
    mintrdiff=999999.9
    thc=0
    epc=0
    for ep=minep,maxep,epint do begin
    thc=0
    for th=minth,maxth,thint do begin
    ;reference pixel
    trdiff=0.0
    for jjjj=-k,k do begin
    for iiii=-k,k do begin
    if (abs(iiii) lt k) and (abs(jjjj) lt k) then begin

    endif else begin
    iref=iiii
    jref=jjjj
    gfctr=sqrt(pxs*(iref^2.0+jref^2.0) + ep^2.0 - 2.0*ep*pxs*(iref*cos(th) + jref*sin(th)))
    gfctr0=sqrt(pxs*(iref^2.0+jref^2.0))

    gvalr=ttt[iref+k,jref+k]

    for jjj=-k,k do begin
    for iii=-k,k do begin
        if ((abs(iii) eq abs(iref)) and (abs(jjj) eq abs(jref))) or ((abs(iii) eq abs(jref)) and (abs(jjj) eq abs(iref))) then begin
        gfct=sqrt(pxs*(iii^2.0+jjj^2.0) + ep^2.0 - 2.0*ep*pxs*(iii*cos(th) + jjj*sin(th)))
        gval=ttt[iii+k,jjj+k]
        valratio=gval/gvalr
        fctratio=gfctr/gfct
        trdiff=trdiff+abs(valratio-fctratio)
    endif
endfor
endfor
endelse
endfor
endfor
    if (trdiff lt mintrdiff) then begin
        mintrdiff=trdiff
        centroids[n,0]=epc
        centroids[n,1]=thc
    endif
thc=thc+1
endfor
epc=epc+1
endfor
endfor

return,centroids


end
