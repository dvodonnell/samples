function pabst_cprofs,bprof1d,cents,klim,sx,minep,minth,epint,thint

print,'Centroid-centering pixel profiles...'
pxs=1.0

for n=0,n_elements(sx)-1 do begin

ep=(cents[n,0]*epint)+minep
th=(cents[n,1]*thint)+minth

    for jjj=-klim,klim do begin
    for iii=-klim,klim do begin
        if (iii ne 0) and (jjj ne 0) then begin
        greg=sqrt(pxs*(iii^2.0+jjj^2.0))
        gfct=sqrt(pxs*(iii^2.0+jjj^2.0) + ep^2.0 - 2.0*ep*pxs*(iii*cos(th) + jjj*sin(th)))
        bprof1d[n,iii+klim,jjj+klim]=bprof1d[n,iii+klim,jjj+klim]*(greg/gfct)
        endif
    endfor
endfor

endfor

return,bprof1d

end
