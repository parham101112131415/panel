import { FC } from 'react'

const FooterContent = () => {
  return (
    <p className="text-muted-foreground inline-block flex-grow text-center text-xs">
      Made with 🔥 by &nbsp;
      <span className="text-primary font-semibold">Parham</span>
    </p>
  )
}

export const Footer: FC = ({ ...props }) => {
  return (
    <div className="relative flex w-full pt-1 pb-3" {...props}>
      <FooterContent />
    </div>
  )
}
