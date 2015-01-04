pro pabst

fp='t'

close,/all
t=readfits('../MIPSdata/RCSscsm15/mosaic/Combine/mosaic_0.fits',/silent)
h=headfits('../MIPSdata/RCSscsm15/mosaic/Combine/mosaic_0.fits')
nx=sxpar(h,'NAXIS1')
ny=sxpar(h,'NAXIS2')

klim=10

xax=fltarr(1)
yax=fltarr(1)
xax[0]=0.0
yax[0]=0.0


if (fp ne 'f') then begin
    num=1000
    scnt=0
    xcoords=fltarr(num)
    ycoords=fltarr(num)
    if (FILE_TEST('sources.dat')) then begin
        readcol,'../MIPSdata/RCSscsm15/sources/ppp_pass1.pos',sx,sy,/silent
        xcoords=sx[0:num-1]
        ycoords=sy[0:num-1]
    endif
    tbright=9999.99
    lbright=0.0
    profiles=fltarr(num,(2*klim)+1,(2*klim)+1)
    distance=fltarr(num,(2*klim)+1,(2*klim)+1)
    iprofiles=fltarr(num,(2*klim)+1,(2*klim)+1)
    srcz=fltarr(num,((2*klim)+1)^2.0)
    srcx=fltarr(num,((2*klim)+1))
    srcy=fltarr(num,((2*klim)+1))
    while (scnt lt num) do begin
        if (xcoords[scnt] eq 0.0) then begin
        lbright=0.0
        for i=0,nx-1 do begin
        for j=0,ny-1 do begin
            taken='f'
            for k=0,scnt do begin
                if (abs(i-xcoords[k]) lt 10) and (abs(j-ycoords[k]) lt 10) and (k ne scnt) then begin
                    taken='t'
                endif
            endfor
            if (t[i,j] gt lbright) and (t[i,j] lt tbright) and (taken eq 'f') then begin
                lbright=t[i,j]
                xcoords[scnt]=i
                ycoords[scnt]=j
            endif
        endfor
        endfor
        print,scnt,lbright,xcoords[scnt],ycoords[scnt]
        tbright=lbright
        endif

        cntrd,t,xcoords[scnt],ycoords[scnt],xc,yc,klim/6.0
        ec=sqrt((xc-xcoords[scnt])^2.0+(yc-ycoords[scnt])^2.0)
        th=atan((yc-ycoords[scnt])/(xc-xcoords[scnt]))

        pxs=1.0
        !p.multi=0
        srcxr=fltarr((2*klim)+1)
        srcyr=fltarr((2*klim)+1)
        for q=-klim,klim do begin
            srcxr[q+klim]=q
            srcyr[q+klim]=q
        endfor
        plot,xax,yax,xrange=[0,klim+1],yrange=[0,1]
        pcnt=0
            for i=-klim,klim do begin
            for j=-klim,klim do begin
                if (i eq 0) and (j eq 0) then begin
                    profiles[scnt,i+klim,j+klim]=1.0
                    distance[scnt,i+klim,j+klim]=0.0
                endif else begin
                    srcx[scnt,i+klim]=i+(ec*cos(th))
                    srcy[scnt,j+klim]=j+(ec*sin(th))
                    srcz[scnt,pcnt]=t[xcoords[scnt]+i,ycoords[scnt]+j]/t[xcoords[scnt],ycoords[scnt]]
                    distance[scnt,i+klim,j+klim]=sqrt(pxs*(i^2.0+j^2.0) + ec^2.0 - 2.0*ec*pxs*(i*cos(th) + j*sin(th)))
                    profiles[scnt,i+klim,j+klim]=t[xcoords[scnt]+i,ycoords[scnt]+j]/t[xcoords[scnt],ycoords[scnt]]
                    ;xax[0]=distance[scnt,i+klim,j+klim]
                    ;yax[0]=profiles[scnt,i+klim,j+klim]
                    oplot,xax,yax,psym=4
                endelse
                pcnt=pcnt+1
            endfor
            endfor
            xi = interpol(indgen(21),srcx[scnt,*],srcxr)
            yi = interpol(indgen(21),srcy[scnt,*],srcyr)
            ngrid=[xi,yi]
            xx = Rebin(xi, 2*klim+1, 2*klim+1, /SAMPLE)
            yy = Rebin(Reform(yi, 1, 2*klim+1), 2*klim+1, 2*klim+1, /SAMPLE)
            zz=interpolate(profiles[scnt,*,*],xx,yy)
            iprofiles[scnt,*,*]=zz
            contour,zz,nlevels=klim*2,xrange=[7,13],yrange=[7,13]            
            scnt=scnt+1
    endwhile
    bprof=fltarr(2*klim+1,2*klim+1)
    for i=-klim,klim do begin
    for j=-klim,klim do begin
        bprof[i+klim,j+klim]=median(iprofiles[*,i+klim,j+klim])
    endfor
    endfor
    bprof=bprof/max(bprof)

    contour,bprof,nlevels=klim*2,xrange=[7,13],yrange=[7,13]
    ks=fltarr(2*klim+1)
    for k=-klim,klim do ks[k+klim]=k
    plot,ks,bprof[*,klim]

endif

;pull in sources
;readcol,'sources.dat',sx,sy,/silent

;load initial profiles in for all sources (centroided)
bprofs=fltarr(n_elements(sx),2*klim+1,2*klim+1)
for k=0,n_elements(sx)-1 do begin
    print,'Centroiding PSF for source ',k
    srcx=fltarr(2*klim+1)
    srcy=fltarr(2*klim+1)
    cntrd,t,sx[k],sy[k],xc,yc,klim/6.0
    ec=sqrt((xc-sx[k])^2.0+(yc-sy[k])^2.0)
    th=atan((yc-sy[k])/(xc-sx[k]))
    for i=-klim,klim do begin
    for j=-klim,klim do begin
    srcx[i+klim]=i+(ec*cos(th))
    srcy[j+klim]=j+(ec*sin(th))
    endfor
    endfor
    xi = interpol(indgen(21),srcx,srcxr)
    yi = interpol(indgen(21),srcy,srcyr)
    ngrid=[xi,yi]
    xx = Rebin(xi, 2*klim+1, 2*klim+1, /SAMPLE)
    yy = Rebin(Reform(yi, 1, 2*klim+1), 2*klim+1, 2*klim+1, /SAMPLE)
    bprofs[k,*,*]=interpolate(bprof,xx,yy)    
    for i=-klim,klim do begin
    for j=-klim,klim do begin
        if finite(bprofs[k,i+klim,j+klim] ne 1) then begin
            bprofs[k,i+klim,j+klim]=0.0
        endif
    endfor
    endfor
endfor

xs=fltarr(n_elements(sx))
xs[*]=0.0
peakvals=pabst_deblend(t,bprofs,sx,sy,klim,xs,0.0,0.0)

;!p.multi=[0,2,2]
goodecs=fltarr(n_elements(sx))
goodths=fltarr(n_elements(sx))
for k=0,-1 do begin
contour,(t[sx[k]-(klim):sx[k]+(klim),sy[k]-(klim):sy[k]+(klim)])-(bprofs[k,*,*]*peakvals[k]),nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
;for k=0,n_elements(sx)-1 do begin
    print,'Centroiding PSF for source ',k
    lstd=1000
    numit=6
    llec=0.0
    ulec=0.5
    llth=0.0
    ulth=6.28
    ecint=0.1
    thint=0.628
    shint=0.5
    llsh=1.0
    ulsh=3.0
    numcnt=0
    while (numcnt lt numit) do begin
    for ec=llec,ulec,ecint do begin
    for th=llth,ulth,thint do begin
    for sh=llsh,ulsh,shint do begin
    srcx=fltarr(2*klim+1)
    srcy=fltarr(2*klim+1)
;    cntrd,t,sx[k],sy[k],xc,yc,klim/6.0
;    ec=sqrt((xc-sx[k])^2.0+(yc-sy[k])^2.0)
;    th=atan((yc-sy[k])/(xc-sx[k]))
    for i=-klim,klim do begin
    for j=-klim,klim do begin
    srcx[i+klim]=i+(ec*cos(th))
    srcy[j+klim]=j+(ec*sin(th))
endfor
endfor
    xi = interpol(indgen(21),srcx,srcxr)
    yi = interpol(indgen(21),srcy,srcyr)
    ngrid=[xi,yi]
    xx = Rebin(xi, 2*klim+1, 2*klim+1, /SAMPLE)
    yy = Rebin(Reform(yi, 1, 2*klim+1), 2*klim+1, 2*klim+1, /SAMPLE)
    bprofs[k,*,*]=interpolate(bprof,xx,yy)
    bprofs[k,*,*]=bprofs[k,*,*]*sh
    bprofs[k,*,*]=bprofs[k,*,*]/max(bprofs[k,*,*])
;    contour,t[sx[k]-klim:sx[k]+klim,sy[k]-klim:sy[k]+klim],nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
;    contour,bprofs[k,*,*],nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
;    contour,(t[sx[k]-(klim):sx[k]+(klim),sy[k]-(klim):sy[k]+(klim)])-(bprofs[k,*,*]*peakvals[k]),nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
    diff=(t[sx[k]-(klim):sx[k]+(klim),sy[k]-(klim):sy[k]+(klim)])-(bprofs[k,*,*]*peakvals[k])
    contour,(t[sx[k]-(klim):sx[k]+(klim),sy[k]-(klim):sy[k]+(klim)])-(bprofs[k,*,*]*t[sx[k],sy[k]]),nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13],/overplot
    wait,0.05
    ;maxd=max(diff,min=mind)
    ;stdd=maxd-mind
    stdd=stddev(diff)
;    print,maxd,mind
    if (stdd lt lstd) then begin
        lstd=stdd
        lth=th
        lec=ec
        lsh=sh
        lbprof=bprofs[k,*,*]
        ;ldiff=diff
;        print,lstd,' new low'
    endif else begin
;        print,stdd
    endelse
;    wait,0.1
endfor
endfor
endfor
llec=lec-ecint
ulec=lec+ecint
llth=lth-thint
ulth=lth+thint
ecint=ecint/10.0
thint=thint/10.0
llsh=lsh-shint
ulsh=lsh+shint
numcnt=numcnt+1
endwhile
print,'For source ',k,' best fit was ',lec,lth
bprofs[k,*,*]=lbprof
goodecs[k]=lec
goodths[k]=lth
contour,ldiff,nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
wait,1.0
endfor

;alternate re-centroiding/re-shaping code
for k=0,n_elements(sx)-1 do begin
print,'Re-centroiding ',k
for p=0,10 do begin
    for i=-klim,klim do begin
    for j=-klim,klim do begin
        pdiff=t[sx[k]+i,sy[k]+j]-bprofs[k,i+klim,j+klim]
        bprofs[k,i+klim,j+klim]=bprofs[k,i+klim,j+klim]+(pdiff*bprofs[k,i+klim,j+klim])
    endfor
    endfor
        bprofs[k,*,*]=bprofs[k,*,*]-min(bprofs[k,*,*])
        bprofs[k,*,*]=bprofs[k,*,*]/max(bprofs[k,*,*])
        ;contour,(t[sx[k]-(klim):sx[k]+(klim),sy[k]-(klim):sy[k]+(klim)])-(bprofs[k,*,*]*peakvals[k]),nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
        ;wait,1
endfor
endfor

;REGENERATE ideal PSF based on better centroids
scnt=0
num=0
if (num gt 0) then begin
;num=round(n_elements(sx)*0.1)
    profiles=fltarr(num,(2*klim)+1,(2*klim)+1)
    distance=fltarr(num,(2*klim)+1,(2*klim)+1)
    iprofiles=fltarr(num,(2*klim)+1,(2*klim)+1)
    srcz=fltarr(num,((2*klim)+1)^2.0)
    srcx=fltarr(num,((2*klim)+1))
    srcy=fltarr(num,((2*klim)+1))
bprof2=fltarr(2*klim+1,2*klim+1)
bprof3=fltarr(2*klim+1,2*klim+1)
while (scnt lt num) do begin
        pxs=1.0
        th=goodths[scnt]
        ec=goodecs[scnt]
        srcxr=fltarr((2*klim)+1)
        srcyr=fltarr((2*klim)+1)
        for q=-klim,klim do begin
            srcxr[q+klim]=q
            srcyr[q+klim]=q
        endfor
        pcnt=0
            for i=-klim,klim do begin
            for j=-klim,klim do begin
                if (i eq 0) and (j eq 0) then begin
                    profiles[scnt,i+klim,j+klim]=1.0
                    distance[scnt,i+klim,j+klim]=0.0
                endif else begin
                    srcx[scnt,i+klim]=i+(ec*cos(th))
                    srcy[scnt,j+klim]=j+(ec*sin(th))
                    srcz[scnt,pcnt]=t[sx[scnt]+i,sy[scnt]+j]/t[sx[scnt],sy[scnt]]
                    distance[scnt,i+klim,j+klim]=sqrt(pxs*(i^2.0+j^2.0) + ec^2.0 - 2.0*ec*pxs*(i*cos(th) + j*sin(th)))
                    profiles[scnt,i+klim,j+klim]=t[sx[scnt]+i,sy[scnt]+j]/t[sx[scnt],sy[scnt]]
                endelse
                pcnt=pcnt+1
            endfor
        endfor
            xi = interpol(indgen(21),srcx[scnt,*],srcxr)
            yi = interpol(indgen(21),srcy[scnt,*],srcyr)
            ngrid=[xi,yi]
            xx = Rebin(xi, 2*klim+1, 2*klim+1, /SAMPLE)
            yy = Rebin(Reform(yi, 1, 2*klim+1), 2*klim+1, 2*klim+1, /SAMPLE)
            zz=interpolate(profiles[scnt,*,*],xx,yy)
            iprofiles[scnt,*,*]=zz
;            print,xi,yi,
            ;plot,ks,iprofiles[scnt,*,klim]
            ;wait,1
            scnt=scnt+1
        endwhile
        bprofold=bprof
;plot,xax,yax,xrange=[-klim,klim],yrange=[0,1.5]
    for i=-klim,klim do begin
    for j=-klim,klim do begin
        if (median(iprofiles[*,i+klim,j+klim]) ge 0.0) then begin
        bprof[i+klim,j+klim]=median(iprofiles[*,i+klim,j+klim])
    endif else begin
        bprof[i+klim,j+klim]=0.0
        endelse
        meanclip,iprofiles[*,i+klim,j+klim],cmean,csig,clipsig=1.0
        h1=histogram(iprofiles[*,i+klim,j+klim],binsize=1.0/(round(num/5)),locations=locs,min=0.0,max=1.0)
        ;h1=hist(iprofiles[*,i+klim,j+klim],xs,(1.0/(round(num/10))))
;        plot,locs,h1
;        wait,1
        yah=max(h1,subsc)
        mode=locs[subsc]
        ;throw out points around the MODE

        ;bprof[i+klim,j+klim]=mode

;        print,subsc,i,j,mode

;        if (j eq 0) then begin
;        for p=0,num-1 do begin
;            xax[0]=i
;            yax[0]=iprofiles[p,i+klim,j+klim]
;            oplot,xax,yax,psym=2
;        endfor
;        wait,2
;        endif
        ;bprof[i+klim,j+klim]=cmean
        bprof2[i+klim,j+klim]=median(iprofiles[*,i+klim,j+klim])
        bprof3[i+klim,j+klim]=mean(iprofiles[*,i+klim,j+klim])

    endfor
endfor
;plothist,iprofiles[*,klim,klim],bin=0.05,xrange=[0,1.5]
;plothist,iprofiles[*,klim-2,klim],/overplot,color=2000,bin=0.05
;plothist,iprofiles[*,klim+2,klim],/overplot,color=6000,bin=0.05
    bprof=bprof/max(bprof)
    ;bprof2=bprof2/max(bprof2)
    ;bprof3=bprof3/max(bprof3)
endif

ks=[-10,-9,-8,-6,-5,-4,-2,-1,0,1,2,3,4,5,6,7,8,9,10]
;plot,ks,bprofold[*,klim]
;oplot,ks,bprof[*,klim],color=2000,thick=2
;oplot,ks,bprof2[*,klim],color=8000
;oplot,ks,bprof3[*,klim],color=15000

;REGENERATE all source profiles
;load initial profiles in for all sources (centroided)
;bprofs=fltarr(n_elements(sx),2*klim+1,2*klim+1)
for k=0,-1 do begin
;for k=0,n_elements(sx)-1 do begin
    print,'Re-centroiding PSF for source ',k
    srcx=fltarr(2*klim+1)
    srcy=fltarr(2*klim+1)
    ec=goodecs[k]
    th=goodths[k]
    for i=-klim,klim do begin
    for j=-klim,klim do begin
    srcx[i+klim]=i+(ec*cos(th))
    srcy[j+klim]=j+(ec*sin(th))
endfor
endfor
    xi = interpol(indgen(21),srcx,srcxr)
    yi = interpol(indgen(21),srcy,srcyr)
    ngrid=[xi,yi]
    xx = Rebin(xi, 2*klim+1, 2*klim+1, /SAMPLE)
    yy = Rebin(Reform(yi, 1, 2*klim+1), 2*klim+1, 2*klim+1, /SAMPLE)
    bprofs[k,*,*]=interpolate(bprof,xx,yy)
    bprofs[k,*,*]=bprofs[k,*,*]/max(bprofs[k,*,*])
endfor

;get new peaks
peakvals=pabst_deblend(t,bprofs,sx,sy,klim,xs,0.0,0.0)

;sharpen PSF a bit (accounts for spread in blending)




;modify sources
for k=0,-1 do begin

df=1000
lstdd=0
ks=[-10,-9,-8,-6,-5,-4,-2,-1,0,1,2,3,4,5,6,7,8,9,10]
plot,ks,bprofs[k,*,klim]
for p=0,10 do begin
;while (df gt 0.50) do begin
diff=(t[sx[k]-(klim):sx[k]+(klim),sy[k]-(klim):sy[k]+(klim)])-(bprofs[k,*,*]*peakvals[k])

for ii=-klim,klim do begin
for jj=-klim,klim do begin
    if (diff[ii+klim,jj+klim] gt median(t[sx[k]-(klim):sx[k]+(klim),sy[k]-(klim):sy[k]+(klim)])) then begin
        corr=diff[ii+klim,jj+klim]/(peakvals[k]*bprofs[k,ii+klim,jj+klim])
        bprofs[k,ii+klim,jj+klim]=bprofs[k,ii+klim,jj+klim]*(1.0+corr)*bprofs[k,ii+klim,jj+klim]
    endif
endfor
endfor



maxd=max(diff,min=mind)
df=((maxd-mind)/mind)
;bprofs[k,*,*]=bprofs[k,*,*]*df
bprofs[k,*,*]=bprofs[k,*,*]/bprofs[k,klim,klim]

oplot,ks,bprofs[k,*,klim]
;wait,0.05
;endwhile
endfor

endfor

;show sources

!p.multi=[0,2,2]
for k=0,-1 do begin
;for k=0,n_elements(sx)-1 do begin
    for ii=-3,3 do begin
    for jj=-3,3 do begin
    contour,t[sx[k]-klim:sx[k]+klim,sy[k]-klim:sy[k]+klim],nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
    contour,bprofs[k,*,*],nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
    contour,(t[sx[k]-(klim+ii):sx[k]+(klim+ii),sy[k]-(klim+jj):sy[k]+(klim+jj)])-(bprofs[k,*,*]*peakvals[k]),nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
    contour,(t[sx[k]-(klim+ii):sx[k]+(klim+ii),sy[k]-(klim+jj):sy[k]+(klim+jj)])-(bprofs[k,*,*]*t[sx[k],sy[k]]),nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
    wait,0.5
    endfor
    endfor
    cntrd,t,sx[k],sy[k],xc,yc,klim/6.0
    ec=sqrt((xc-sx[k])^2.0+(yc-sy[k])^2.0)
    th=atan((yc-sy[k])/(xc-sx[k]))
    th=th*(180.0/3.14)
    print,k,sx[k],sy[k],xc,yc,ec,th
    wait,2
endfor
!p.multi=0

;make initial sub image
print,'Printing initial image'
s=t
for k=0,n_elements(sx)-1 do begin
    for i=-klim,klim do begin
    for j=-klim,klim do begin
        s[sx[k]+i,sy[k]+j]=s[sx[k]+i,sy[k]+j]-(peakvals[k]*bprofs[k,i+klim,j+klim])
    endfor
endfor
endfor
writefits,'testsub.fits',s,h

end
