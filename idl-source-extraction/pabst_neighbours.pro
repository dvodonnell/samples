function pabst_neighbours,sx,sy,klim

;store all neighbours (for faster comp times)
dn='f'
if (dn ne 'f') then begin
ns=strarr(2,n_elements(sx))
print,'Finding neighbours...'
openw,nlist,'neighlist.dat',/get_lun
for k=0,n_elements(sx)-1 do begin
    for m=0,n_elements(sx)-1 do begin
        dkm=sqrt((sx[k]-sx[m])^2.0+(sy[k]-sy[m])^2.0)
            if (dkm lt klim) and (m ne k) then begin
                ns[k]=ns[k]+string(m)+';'
            endif
        endfor
printf,nlist,ns[k]
endfor
free_lun,nlist
endif else begin
ns=strarr(n_elements(sx))
openr,nfile,'neighlist.dat',/get_lun
readf,nfile,ns
free_lun,nfile
endelse

return,ns

end
