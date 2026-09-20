import { Button } from '@/components/ui/button'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'
import Snowfall from '@/components/common/snowfall'
import useDirDetection from '@/hooks/use-dir-detection'
import { cn } from '@/lib/utils'
import { LucideIcon, Plus } from 'lucide-react'
import { useTranslation } from 'react-i18next'

interface PageHeaderProps {
  title: string
  description?: string
  buttonText?: string
  onButtonClick?: () => void
  buttonIcon?: LucideIcon
  buttonTooltip?: string
  tutorialUrl?: string
  className?: string
}

export default function PageHeader({ title, description, buttonText, onButtonClick, buttonIcon: Icon = Plus, buttonTooltip, className }: PageHeaderProps) {
  const { t } = useTranslation()
  const dir = useDirDetection()

  return (
    <div dir={dir} className={cn('bg-background/80 sticky top-0 z-20 mx-auto flex w-full flex-row items-start justify-between gap-4 overflow-hidden px-4 py-4 backdrop-blur-md md:pt-6', className)}>
      <Snowfall className="snowfall--header" />
      <div className="relative z-10 flex min-w-0 flex-1 flex-col gap-y-1">
        <div className="flex min-w-0 items-center gap-2.5">
          <h1 className="truncate text-2xl font-semibold tracking-tight">{t(title)}</h1>
        </div>
        {description && <span className="text-muted-foreground text-sm leading-relaxed whitespace-normal">{t(description)}</span>}
      </div>
      {buttonText && onButtonClick && (
        <div className="relative z-10 shrink-0">
          {buttonTooltip ? (
            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger asChild>
                  <Button className="flex items-center" onClick={onButtonClick} size="sm">
                    {Icon && <Icon />}
                    <span>{t(buttonText)}</span>
                  </Button>
                </TooltipTrigger>
                <TooltipContent>
                  <p>{buttonTooltip}</p>
                </TooltipContent>
              </Tooltip>
            </TooltipProvider>
          ) : (
            <Button className="flex items-center" onClick={onButtonClick} size="sm">
              {Icon && <Icon />}
              <span>{t(buttonText)}</span>
            </Button>
          )}
        </div>
      )}
    </div>
  )
}
