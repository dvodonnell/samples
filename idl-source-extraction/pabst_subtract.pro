function pabst_subtract,t,sx,sy,ns,bprof,klim,peaks,k

tt=t[sx[k]-klim:sx[k]+klim,sy[k]-klim:sy[k]+klim]

        neighs=strsplit(ns[k], ';', /extract)
        for m=0,n_elements(neighs)-1 do begin
            if (neighs[m] ne '') then begin
                for i=-klim,klim do begin
                for j=-klim,klim do begin
                    if (i-(sx[float(neighs[m])]-sx[k])+klim) lt klim and (j-(sy[float(neighs[m])]-sy[k])+klim) lt klim and (i-(sx[float(neighs[m])]-sx[k])+klim) ge 0 and (j-(sy[float(neighs[m])]-sy[k])+klim) ge 0 then begin
                    tt[i+klim,j+klim]=tt[i+klim,j+klim]-(peaks[float(neighs[m])]*(bprof[float(neighs[m]),i-(sx[float(neighs[m])]-sx[k])+klim,j-(sy[float(neighs[m])]-sy[k])+klim]))
                    endif
                endfor
                endfor
            endif
        endfor
    

        return,tt


end
