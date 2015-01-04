function pabst_deblend,t,bprof,sx,sy,klim,xs,tpx,tpy

;correlation threshold in klim distances (to speed up)
ths=4.0

ns=pabst_neighbours(sx,sy,klim)
diff=1.0
n=1
while (diff gt 1E-5) do begin
;    print,'doing',n
    diff=0.0
    for k=0,n_elements(sx)-1 do begin
        if (sqrt((tpx-sx[k])^2.0+(tpy-sy[k])^2.0) lt ths*klim) or ((tpx eq 0.0) and (tpy eq 0.0)) then begin
        cont=0.0
        neighs=strsplit(ns[k], ';', /extract)
        for m=0,n_elements(neighs)-1 do begin
            if (neighs[m] ne '') then begin
;            dkm=sqrt((sx[k]-sx[float(neighs[m])])^2.0+(sy[k]-sy[float(neighs[m])])^2.0)
;            if (dkm lt klim) then begin
                kkm=bprof[float(neighs[m]),(sx[float(neighs[m])]-sx[k]+klim),(sy[float(neighs[m])]-sy[k]+klim)]
;                kkm=interpolate(bprof,[dkm])
;                print,float(neighs[m]),sx[float(neighs[m])],sy[float(neighs[m])],sx[k],sy[k],k,kkm,(sx[float(neighs[m])]-sx[k]+klim),(sy[float(neighs[m])]-sy[k]+klim)
                cont=cont+(kkm*xs[float(neighs[m])])
;            endif
            endif
        endfor
        diff=diff+abs(xs[k]-(t[sx(k),sy(k)]-cont))
        print,cont,sx[k],sy[k],diff,finite(diff)
        if (finite(diff) ne 1) then wait,10
        xs[k]=t[sx(k),sy(k)]-cont
        ;if (k eq 1000) then print,xs[k]
        endif
    endfor
    print,'diff was ',diff
    n=n+1
endwhile

return,xs

end
