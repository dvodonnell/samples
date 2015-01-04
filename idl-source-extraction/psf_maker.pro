pro psf_maker,xc,yc,size

fs='f'
fp='f'

close,/all

t=readfits('../MIPSdata/RCSscsm15/mosaic/Combine/mosaic_0.fits',/silent)
h=headfits('../MIPSdata/RCSscsm15/mosaic/Combine/mosaic_0.fits')
nx=sxpar(h,'NAXIS1')
ny=sxpar(h,'NAXIS2')

sig=stddev(t)
maxval=max(t)
med=median(t)
meanclip,t,rmean,rsig,clipsig=3.0
print,stddev(t)

klim=10


;check for nice isolated bright round sources
if (fp ne 'f') then begin
num=50
profiles=fltarr(num,klim)
weights=fltarr(num,klim)
xcoords=fltarr(num)
ycoords=fltarr(num)
tbright=9999.99
lbright=0.0
scnt=0
xax=fltarr(1)
yax=fltarr(1)
xax[0]=0.0
yax[0]=0.0
plot,xax,yax,xrange=[0,12],yrange=[0,1.0]
while (scnt lt num) do begin
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

minec1=9.9
minth1=9.9
pvals1=fltarr(klim)
pvals2=fltarr(klim)
ks=fltarr(klim)
ks0=fltarr(klim+1)
ks0[0]=0
stopks='f'
for k=1,klim do begin
    if (stopks eq 'f') then begin
    ks[k-1]=k
    ks0[k]=k
    tt=fltarr((2*k+1)^2)
    cnt=0
    for ii=(xcoords[scnt]-k),(xcoords[scnt]+k) do begin
    for jj=(ycoords[scnt]-k),(ycoords[scnt]+k) do begin
        tt[cnt]=t[ii,jj]
        cnt=cnt+1
    endfor
    endfor  
    ttt=t[(xcoords[scnt]-k):(xcoords[scnt]+k),(ycoords[scnt]-k):(ycoords[scnt]+k)]
;    plot,tt
    ;find local maxima
    highval=0.0
    highm=0
    lsig=stddev(tt)
    ;print,mean(tt),lsig
    lm=0
    for m=0,n_elements(tt)-1 do begin
        if (lm eq (2*k+1)) then begin
                xax=fltarr(2)
                yax=fltarr(2)
                xax[0]=m
                xax[1]=m
                yax[0]=0.0
                yax[1]=10.0
                ;oplot,xax,yax,color=20000  
                lm=0
            endif
            lm=lm+1
        if (tt[m] gt highval) and (tt[m] gt (0.2*lsig)) then begin
            highval=tt[m]
            highm=m
            endif
        if (tt[m] lt (0.2*lsig)) then begin
            if (highval gt 0.0) then begin
                xax=fltarr(1)
                yax=fltarr(1)
                xax[0]=highm
                yax[0]=highval
                ;oplot,xax,yax,psym=4,color=2000,symsize=4
            endif
            highval=0.0
        endif
    endfor
    ;check symmetry
    pxs=1.0
    mintrdiff=999999.9
;    for ep=0.0,0.5,0.01 do begin
;    for th=0.0,6.28,0.0628 do begin
    for ep=0.0,0.5,0.1 do begin
    for th=0.0,6.28,0.628 do begin
    ;reference pixel
    trdiff=0.0
    avgratio=fltarr(4)
    avgratiod=fltarr(4)
    avgcnt=0
    for jjjj=-k,k do begin
    for iiii=-k,k do begin
    if (abs(iiii) lt k) and (abs(jjjj) lt k) then begin

    endif else begin
    iref=iiii
    jref=jjjj
    gfctr=sqrt(pxs*(iref^2.0+jref^2.0) + ep^2.0 - 2.0*ep*pxs*(iref*cos(th) + jref*sin(th)))
    gfctr0=sqrt(pxs*(iref^2.0+jref^2.0))
    
    gvalr=ttt[iref+k,jref+k]
    if ((iref eq k) and (jref eq 0)) or ((iref eq -k) and (jref eq 0)) or ((iref eq 0) and (jref eq k)) or ((iref eq 0) and (jref eq -k)) then begin
;    avgratio[avgcnt]=((gvalr/ttt[k,k])*(gfctr/gfctr0)*(sqrt(pxs*(k^2.0))/gfctr0))
    avgratio[avgcnt]=(gvalr/ttt[k,k])    
    avgratiod[avgcnt]=gfctr
    avgcnt=avgcnt+1
    endif
    if (iref eq 0) and (jref eq k) then begin
        testval=(gvalr/ttt[k,k])*(gfctr/gfctr0)
    endif
;    if (k eq 2) then print,'gref ',iref,jref
    for jjj=-k,k do begin
    for iii=-k,k do begin
        if ((abs(iii) eq abs(iref)) and (abs(jjj) eq abs(jref))) or ((abs(iii) eq abs(jref)) and (abs(jjj) eq abs(iref))) then begin
;        if (abs(iii) lt k) and (abs(jjj) lt k) then begin
;        endif else begin
        gfct=sqrt(pxs*(iii^2.0+jjj^2.0) + ep^2.0 - 2.0*ep*pxs*(iii*cos(th) + jjj*sin(th)))
        gval=ttt[iii+k,jjj+k]
        valratio=gval/gvalr
        fctratio=gfctr/gfct
;        trdiff=trdiff+abs(1-valratio)
        trdiff=trdiff+abs(valratio-fctratio)
;        if (k eq 2) then print,'  ',k,iii,jjj,valratio,fctratio,trdiff
        ;print,k,iii,jjj,ttt[iii+k,jjj+k],(ttt[iii+k,jjj+k]/ttt[k,k]),gfct
    endif
    endfor
    endfor
    endelse
    endfor
endfor
;    print,'running e=',ep,' and th=',th,' with tdiff=',trdiff
    if (trdiff lt mintrdiff) then begin
        mintrdiff=trdiff
        minec=ep
        minth=th
        mintestval=testval
        ;minavg=avgratio/(k*8.0)
        meanclip,avgratio,minavg,sig,clipsig=3.0
        if (k eq 1) then begin
            minec1=ep
            minth1=th
        endif
    endif
    if (ep eq minec1) and (th eq minth1) then begin
        mintrdiff1=trdiff
        ;minavg1=avgratio/(k*8.0)
        
        meanclip,avgratio,minavg1,sig1,clipsig=3.0
        mintestval1=testval
    endif
    endfor
    endfor
    pvals1[k-1]=minavg1
    pvals2[k-1]=mintestval1
    print,'Total assymetry factor for k=',k,' is ',mintrdiff,mintrdiff1,minavg,minavg1,' (for e=',minec,' and th=',minth,')'
    profiles[scnt,k-1]=minavg1
    weights[scnt,k-1]=(1.0/mintrdiff)
    ;if (minavg1 lt rmean) then stopks='t'
    ;extract the source
    if (mintrdiff lt 2.0) then begin
;        refval=
;        for ii=xcoords[scnt]-6,xcoords[scnt]+6 do begin
;        for jj=ycoords[scnt]-6,ycoords[scnt]+6 do begin
;          t[ii,jj]=t[ii,jj]-(t[ii,jj]-median(t))  
;        endfor
;        endfor
    endif
    ;wait,1
endif else begin
    profiles[scnt,k-1]=0.0
    weights[scnt,k-1]=0.0
    pvals1[k-1]=0.0
    pvals2[k-1]=0.0
endelse
endfor

oplot,ks,pvals1
oplot,ks,pvals2,color=20000

;wait,2
scnt=scnt+1
endwhile

;find best profile
openw,outunit,'profile.dat',/get_lun
bprof=fltarr(klim+1)
bprof[0]=1.0
printf,outunit,0,1.0
for i=1,klim do begin
    if (total(weights[*,i-1]) gt 0.0) then begin
    bprof[i]=wtd_mean(profiles[*,i-1],weights[*,i-1])
    printf,outunit,i,bprof[i]
    endif
endfor
free_lun,outunit

oplot,ks0,bprof,color=2000

endif else begin
readcol,'profile.dat',ks,bprof,/silent
endelse

;get pixel areas
;pxas=pabst_pixval(klim,bprof)

if (fs ne 'f') then begin
;find sources!
sigcnt=(maxval-rmean)/rsig
sigint=((sigcnt-1.5)/100.0)
intf=sigint
srccnt=0
openw,outunit,'sources.dat',/get_lun
openw,outunitt,'sources.reg',/get_lun
free_lun,outunit
tbad=t
while (sigcnt gt 0.25) do begin
    cursrcs=0
    print,'Checking sources above ',sigcnt,' sigma.'
    for i=0,nx-1 do begin
    for j=0,ny-1 do begin
        newsrc='f'
        if (t[i,j] gt (rmean+(sigcnt*rsig))) and (tbad[i,j] ne 0.0) then begin
            newsrc='t'
            if (srccnt gt 0) then begin
                 readcol,'sources.dat',srcx,srcy,/silent
            for k=0,n_elements(srcx)-1 do begin
                dist=sqrt((i-srcx[k])^2.0+(j-srcy[k])^2.0)
                if (dist le klim) then begin
                ;check for too close or too faint cases
                if (t[i,j] lt t[srcx[k],srcy[k]]*(interpolate(bprof,[dist])+((interpolate(bprof,[dist]))*0.3))) or (dist lt 2.0) then begin
                   newsrc='f'
               endif
                ;check for contiguous (no intersecting minimum) cases
                if (t[i,j] gt t[srcx[k],srcy[k]]*(interpolate(bprof,[dist])+((interpolate(bprof,[dist]))*0.3))) and (dist ge 2.0) then begin
                   ;now check if pixels in between are lower
                    isok='f'
                   if (abs(i-srcx[k]) gt abs(j-srcy[k])) then begin
                   ath=atan((j-srcy[k])/(i-srcx[k]))
                   if ((i-srcx[k]) lt 0) then tstep=1
                   if ((i-srcx[k]) gt 0) then tstep=-1
                   for m=(i-srcx[k]),(tstep*(-1)),tstep do begin
                       n=round(tan(ath)*m)
                       ti=m+srcx[k]
                       tj=round(n+srcy[k])
;                       print,i,j,ti,tj,t[i,j],t[ti,tj],srcx[k],srcy[k]
                       if (t[ti,tj] lt t[i,j]) then isok='t'
                   endfor
               endif else begin
                   ath=atan((i-srcx[k])/(j-srcy[k]))
                   if ((j-srcy[k]) lt 0) then tstep=1
                   if ((j-srcy[k]) gt 0) then tstep=-1
                   for n=(j-srcy[k]),(tstep*(-1)),tstep do begin
                       m=round(tan(ath)*n)
                       ti=round(m+srcx[k])
                       tj=n+srcy[k]
;                       print,m,n,ath,ti,tj
;                       print,i,j,ti,tj,t[i,j],t[ti,tj],srcx[k],srcy[k]
                       if (t[ti,tj] lt t[i,j]) then isok='t'
                   endfor
               endelse
               if (isok eq 'f') then newsrc='f'
               endif
               ;done checking for bad sources because of other sources
                endif
            endfor
               ;check for too sharp cases (radhits, noise, etc.)
               if (newsrc eq 't') then begin
               tfactor=0.65
               ;possibly do this in next step?
               if ((t[i,j+1]+t[i,j-1]+t[i+1,j]+t[i-1,j])/4.0 lt (t[i,j]*bprof[1]*tfactor)) then newsrc='f'
               if ((t[i,j+1]+t[i,j-1]+t[i+1,j]+t[i-1,j])/4.0 lt (t[i,j]*bprof[1]*tfactor)) then print,'too sharp',i,j
               ;if (t[i,j+1] lt (t[i,j]*bprof[1]*tfactor)) or (t[i,j-1] lt (t[i,j]*bprof[1]*tfactor)) or (t[i+1,j] lt (t[i,j]*bprof[1]*tfactor)) or (t[i-1,j] lt (t[i,j]*bprof[1]*tfactor)) then newsrc='f'
               ;if (t[i,j+1] lt (t[i,j]*bprof[1]*tfactor)) or (t[i,j-1] lt (t[i,j]*bprof[1]*tfactor)) or (t[i+1,j] lt (t[i,j]*bprof[1]*tfactor)) or (t[i-1,j] lt (t[i,j]*bprof[1]*tfactor)) then print,'too sharp',t[i-1,j],t[i,j],bprof[1],tfactor,i,j
               endif
               ;done checking for bad sources (all reasons)
        endif
            if (newsrc eq 't') then begin
                print,'Found new source (#',srccnt,') at ',i,',',j,' with flux ',t[i,j]                
                openw,outunit,/append,'sources.dat',/get_lun
                printf,outunit,i,j
                free_lun,outunit
                printf,outunitt,"circle(",i+1,",",j+1,",1.5)",format='(A7,I4,A1,I4,A5)'
                srccnt=srccnt+1
                cursrcs=cursrcs+1
            endif else begin
                tbad[i,j]=0.0
            endelse
        endif
    endfor
endfor
    if (cursrcs eq 0) then cursrcs=1
    if (cursrcs gt 10) then intf=intf/((cursrcs-10))
    if (srccnt gt 0) then begin
     sigcnt=sigcnt-intf
;    sigcnt=sigcnt-((sigint/srccnt)+0.1)
endif else begin
    sigcnt=sigcnt-sigint
endelse
endwhile
free_lun,outunitt
endif

;perform source analysis/rejection
readcol,'sources.dat',sx,sy,/silent
r1=0
r2=0
openw,o1,'rej1.reg',/get_lun
openw,o2,'rej2.reg',/get_lun
printf,o1,'global color=red'
printf,o2,'global color=yellow'
rej=t
for k=0,n_elements(sx)-1 do begin
    ;reject stuff that's just too faint
    tbg=t[(sx[k]-klim):(sx[k]+klim),(sy[k]-klim):(sy[k]+klim)]
    if ((t[sx[k],sy[k]+1]+t[sx[k],sy[k]-1]+t[sx[k]+1,sy[k]]+t[sx[k]-1,sy[k]])/4.0 lt median(tbg)) then begin
        print,'faint test rejects',sx[k],sy[k]
        rej[sx[k],sy[k]]=0.0
        printf,o1,"circle(",sx[k]+1,",",sy[k]+1,",1.5)",format='(A7,I4,A1,I4,A5)'
        r1=r1+1
    endif
          
;    for kk=1,klim do begin
;        ttt=t[(sx[k]-kk):(sx[k]+kk),(sy[k]-kk):(sy[k]+kk)]
;        syminfo=pabst_centroid(ttt,kk)
;        print,sx[k],sy[k],syminfo[0],syminfo[1],syminfo[2],syminfo[3]
;    endfor
endfor

minth=0.0
maxth=6.28
minep=0.0
maxep=0.5
thint=0.628
epint=0.1

;get centroids for all sources
cents=pabst_centroid(t,sx,sy,minth,maxth,minep,maxep,thint,epint)

;get integrals
ints=pabst_integrate(klim,bprof,minth,maxth,minep,maxep,thint,epint,10)

;make profile 2d compatible and unique to all sources
;bprof1d=fltarr(n_elements(sx),(2*klim)+1,(2*klim)+1)
;for k=0,n_elements(sx)-1 do begin
;print,'Pixvals for ',k
;    for i=0,2*klim do begin
;    for j=0,2*klim do begin
;        dist=sqrt((i-klim)^2.0 + (j-klim)^2.0)
;        bprof1d[k,i,j]=interpolate(bprof,[dist])
;    endfor
;    endfor
;endfor
;preturb profiles given centroids
;bprof1d=pabst_cprofs(bprof1d,cents,klim,sx,minep,minth,epint,thint)

bprof2d=pabst_pixval(cents,ints,n_elements(sx),minep,minth,epint,thint,klim)

!p.multi=[0,2,1]
for k=0,n_elements(sx)-1 do begin
act=t[sx[k]-klim:sx[k]+klim,sy[k]-klim:sy[k]+klim]
    contour,bprof2d[k,*,*],nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
    contour,act,nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
    wait,1
endfor

xs=fltarr(n_elements(sx))
xs[*]=0.0
peakvals=pabst_deblend(t,bprof2d,sx,sy,klim,xs,0.0,0.0)

;make initial sub image
s=t
for k=0,n_elements(sx)-1 do begin
    for i=-klim,klim do begin
    for j=-klim,klim do begin
        dist=sqrt((i)^2.0+(j)^2.0)
        s[sx[k]+i,sy[k]+j]=s[sx[k]+i,sy[k]+j]-(peakvals[k]*bprof2d[k,i+klim,j+klim])
    endfor
endfor
endfor
writefits,'testsub.fits',s,h

print,'done initial image'

!p.multi=0
!p.multi=[0,2,2]
;re-centroid unblended
;loadct,3
ns=pabst_neighbours(sx,sy)
;for k=0,n_elements(sx)-1 do begin
;    st=pabst_subtract(t,sx,sy,ns,bprof2d,klim,peakvals,k)
    ;shade_surf,
    ;act=t[sx[k]-klim:sx[k]+klim,sy[k]-klim:sy[k]+klim]
    ;contour,st,nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
    ;contour,act,nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
    ;contour,bprof2d[k,*,*],nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
    ;contour,(st/peakvals[k])-(bprof2d[k,*,*]),nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
    ;wait,5
;endfor

;now loop over sources, checking deviation from bprof and ajusting
;bprof2d for that source, rerunning peakvals
;MUST IGNORE CHANGES THAT ARE SIMILAR IN MAGNITUDE TO BACKGROUND VARAINCE
for z=0,0 do begin
;do subtraction to get better background
s=t
for k=0,n_elements(sx)-1 do begin
    for i=-klim,klim do begin
    for j=-klim,klim do begin
        dist=sqrt((i)^2.0+(j)^2.0)
        s[sx[k]+i,sy[k]+j]=s[sx[k]+i,sy[k]+j]-(peakvals[k]*bprof2d[k,i+klim,j+klim])
    endfor
endfor
endfor
meanclip,s,umean,usig,clipsig=3.0
;check deviation
for k=0,500 do begin
diffgrid=fltarr(2*klim+1,2*klim+1)
;get image value with neighbours removed
st=pabst_subtract(t,sx,sy,ns,bprof2d,klim,peakvals,k)
;for i=-klim,klim do begin
;for j=-klim,klim do begin
    ;diffval=t[sx[k]+i,sy[k]+j]-(peakvals[k]*bprof2d[k,i+klim,j+klim])
    ;if (abs(diffval) gt 2*rsig) then begin
    ;diffgrid[i+klim,j+klim]=(st[i+klim,j+klim]-(peakvals[k]*bprof2d[k,i+klim,j+klim]))/peakvals[k]
    diffgrid=(st/peakvals[k])-(bprof2d[k,*,*])
    ;endif else begin
    ;diffgrid[i+klim,j+klim]=0.0
    ;endelse
;endfor
;endfor
;smooth diffgrid
;meanclip,diffgrid,dmean,dsig,clipsig=3.0
;for i=-klim,klim do begin
;for j=-klim,klim do begin
;if (abs(diffgrid[i+klim,j+klim]) gt 2.0*dsig) then begin
;if (diffgrid[i+klim,j+klim] gt 0) then diffgrid[i+klim,j+klim]=dmean+(2.0*dsig)
;if (diffgrid[i+klim,j+klim] lt 0) then diffgrid[i+klim,j+klim]=(-1.0)*(dmean+(2.0*dsig))
;endif
;endfor
;endfor
diffgrid=smooth(diffgrid,3)
diffgrid=smooth(diffgrid,(klim/2))
;diffgrid=((peakvals[k]*bprof2d[k,*,*])-diffgrid)/peakvals[k]
;diffgrid=diffgrid/max(abs(diffgrid))
;plot,bprof2d[k,klim,*],xrange=[0,20],yrange=[-1.0,1.5]
bprof2d[k,*,*]=bprof2d[k,*,*]+(0.25*diffgrid)
bprof2d[k,*,*]=bprof2d[k,*,*]+(-1.0*min(bprof2d[k,*,*]))
;oplot,bprof2d[k,klim,*],color=3000,thick=1
bfm=max(bprof2d[k,*,*])
bprof2d[k,*,*]=bprof2d[k,*,*]/max(bprof2d[k,*,*])
    act=t[sx[k]-klim:sx[k]+klim,sy[k]-klim:sy[k]+klim]
    contour,st,nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
    contour,act,nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
    contour,bprof2d[k,*,*],nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
    contour,(st/peakvals[k])-(bprof2d[k,*,*]),nlevels=klim*2,/fill,xrange=[7,13],yrange=[7,13]
print,bfm,max(bprof2d[k,*,*])
for i=-klim,klim do begin
for j=-klim,klim do begin
    d=sqrt(i^2.0+j^2.0)
    lfn=sqrt((klim-d)/klim)
    if d gt klim then bprof2d[k,i+klim,j+klim]=0
    if bprof2d[k,i+klim,j+klim] gt lfn then bprof2d[k,i+klim,j+klim]=bprof2d[k,i+klim,j+klim]*lfn
endfor
endfor
;send the sides to zero
;oplot,bprof2d[k,klim,*],color=3000,thick=2
;plot,bprof2d[k,*,klim],xrange=[0,20],yrange=[-1.0,1.5],color=3000,thick=2
print,z,k
;print,bprof2d[k,*,*]
;if (max(bprof2d[k,*,*]) ne bprof2d[k,klim,klim]) or (max(bprof2d[k,*,*]) ne 1.0) then wait,10
;wait,1
peakvals=pabst_deblend(t,bprof2d,sx,sy,klim,peakvals,sx[k],sy[k])
endfor
;peakvals=pabst_deblend(t,bprof2d,sx,sy,klim)
;write fits
s=t
for k=0,n_elements(sx)-1 do begin
    for i=-klim,klim do begin
    for j=-klim,klim do begin
        dist=sqrt((i)^2.0+(j)^2.0)
        s[sx[k]+i,sy[k]+j]=s[sx[k]+i,sy[k]+j]-(peakvals[k]*bprof2d[k,i+klim,j+klim])
    endfor
endfor
endfor
writefits,'testsub_'+string(z)+'.fits',s,h
endfor

free_lun,o1
free_lun,o2
print,r1
print,r2

s=t
for k=0,n_elements(sx)-1 do begin
    for i=-klim,klim do begin
    for j=-klim,klim do begin
        dist=sqrt((i)^2.0+(j)^2.0)
        s[sx[k]+i,sy[k]+j]=s[sx[k]+i,sy[k]+j]-(peakvals[k]*bprof2d[k,i+klim,j+klim])
    endfor
    endfor
endfor

writefits,'finalsub.fits',s,h

end
